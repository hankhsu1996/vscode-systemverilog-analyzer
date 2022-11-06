import {
  Location,
  Position,
  Range,
  SymbolInformation,
  SymbolKind,
  TextDocument,
  DocumentSymbol,
  DocumentHighlight,
  DocumentHighlightKind,
} from "../languageTypes";

import * as nodes from "../parser/nodes";
import { Symbols } from "../parser/symbolScope";

type DocumentSymbolCollector = (
  name: string,
  kind: SymbolKind,
  symbolNodeOrRange: nodes.Node | Range,
  nameNodeOrRange: nodes.Node | Range | undefined,
  bodyNode: nodes.Node[] | undefined
) => void;

export class Navigation {
  public findDefinition(
    document: TextDocument,
    position: Position,
    stylesheet: nodes.Node
  ): Location | null {
    const symbols = new Symbols(stylesheet);
    const offset = document.offsetAt(position);
    const node = nodes.getNodeAtOffset(stylesheet, offset);

    if (!node) {
      return null;
    }

    const symbol = symbols.findSymbolFromNode(node);
    if (!symbol) {
      return null;
    }

    return {
      uri: document.uri,
      range: getRange(symbol.node, document),
    };
  }

  public findReferences(
    document: TextDocument,
    position: Position,
    stylesheet: nodes.SourceText
  ): Location[] {
    const highlights = this.findDocumentHighlights(
      document,
      position,
      stylesheet
    );
    return highlights.map((h) => {
      return {
        uri: document.uri,
        range: h.range,
      };
    });
  }

  public findDocumentHighlights(
    document: TextDocument,
    position: Position,
    stylesheet: nodes.SourceText
  ): DocumentHighlight[] {
    const result: DocumentHighlight[] = [];

    const offset = document.offsetAt(position);
    let node = nodes.getNodeAtOffset(stylesheet, offset);
    if (
      !node ||
      node.type === nodes.NodeType.SourceText ||
      node.type === nodes.NodeType.Declarations
    ) {
      return result;
    }
    if (node.type === nodes.NodeType.Identifier && node.parent) {
      node = node.parent;
    }

    const symbols = new Symbols(stylesheet);
    const symbol = symbols.findSymbolFromNode(node);
    const name = node.getText();

    stylesheet.accept((candidate) => {
      if (symbol) {
        if (symbols.matchesSymbol(candidate, symbol)) {
          result.push({
            kind: getHighlightKind(candidate),
            range: getRange(candidate, document),
          });
          return false;
        }
      } else if (
        node &&
        node.type === candidate.type &&
        candidate.matches(name)
      ) {
        // Same node type and data
        result.push({
          kind: getHighlightKind(candidate),
          range: getRange(candidate, document),
        });
      }
      return true;
    });

    return result;
  }

  public findSymbolInformations(
    document: TextDocument,
    sourceText: nodes.SourceText
  ): SymbolInformation[] {
    const result: SymbolInformation[] = [];

    const addSymbolInformation = (
      name: string,
      kind: SymbolKind,
      symbolNodeOrRange: nodes.Node | Range
    ) => {
      const range =
        symbolNodeOrRange instanceof nodes.Node
          ? getRange(symbolNodeOrRange, document)
          : symbolNodeOrRange;
      const entry: SymbolInformation = {
        name,
        kind,
        location: Location.create(document.uri, range),
      };
      result.push(entry);
    };

    this.collectDocumentSymbols(document, sourceText, addSymbolInformation);

    return result;
  }

  public findDocumentSymbols(
    document: TextDocument,
    sourceText: nodes.SourceText
  ): DocumentSymbol[] {
    const result: DocumentSymbol[] = [];

    const parents: [DocumentSymbol, Range[]][] = [];

    const addDocumentSymbol = (
      name: string,
      kind: SymbolKind,
      symbolNodeOrRange: nodes.Node | Range,
      nameNodeOrRange: nodes.Node | Range | undefined,
      bodyNode: nodes.Node[] | undefined
    ) => {
      const range =
        symbolNodeOrRange instanceof nodes.Node
          ? getRange(symbolNodeOrRange, document)
          : symbolNodeOrRange;
      const selectionRange =
        (nameNodeOrRange instanceof nodes.Node
          ? getRange(nameNodeOrRange, document)
          : nameNodeOrRange) ?? Range.create(range.start, range.start);
      const entry: DocumentSymbol = {
        name,
        kind,
        range,
        selectionRange,
      };
      let top = parents.pop();

      while (top && top[1].every((r) => !containsRange(r, range))) {
        top = parents.pop();
      }
      if (top) {
        const topSymbol = top[0];
        if (!topSymbol.children) {
          topSymbol.children = [];
        }
        topSymbol.children.push(entry);
        parents.push(top); // put back top
      } else {
        result.push(entry);
      }
      if (bodyNode) {
        parents.push([entry, bodyNode.map((n) => getRange(n, document))]);
      }
    };

    this.collectDocumentSymbols(document, sourceText, addDocumentSymbol);

    return result;
  }

  private collectDocumentSymbols(
    document: TextDocument,
    sourceText: nodes.SourceText,
    collect: DocumentSymbolCollector
  ): void {
    sourceText.accept((node) => {
      if (node instanceof nodes.ModuleDeclaration) {
        // Althrough SymbolKind has Module, the module in SystemVerilog
        // is more like a class in other programming languages
        collect(
          node.getName(),
          SymbolKind.Class,
          node,
          node.getIdentifier(),
          node.getDeclarations()
        );
      } else if (node instanceof nodes.PackageDeclaration) {
        collect(
          node.getName(),
          SymbolKind.Package,
          node,
          node.getIdentifier(),
          node.getDeclarations()
        );
      } else if (node instanceof nodes.FunctionDeclaration) {
        collect(
          node.getName(),
          SymbolKind.Function,
          node,
          node.getIdentifier(),
          // TODO: node.getBody()
          undefined
        );
      } else if (node instanceof nodes.TaskDeclaration) {
        collect(
          node.getName(),
          SymbolKind.Function,
          node,
          node.getIdentifier(),
          // TODO: node.getBody()
          undefined
        );
      } else if (node instanceof nodes.ParamAssignment) {
        collect(
          node.getName(),
          SymbolKind.Variable,
          node,
          node.getIdentifier(),
          undefined
        );
      } else if (node instanceof nodes.VariableDeclAssignment) {
        // Check parent. If parent is a StructUnionMember, then it is a field
        if (node.getParent() instanceof nodes.StructUnionMember) {
          collect(
            node.getName(),
            SymbolKind.Field,
            node,
            node.getIdentifier(),
            undefined
          );
        } else {
          collect(
            node.getName(),
            SymbolKind.Variable,
            node,
            node.getIdentifier(),
            undefined
          );
        }
      } else if (node instanceof nodes.NetDeclAssignment) {
        collect(
          node.getName(),
          SymbolKind.Variable,
          node,
          node.getIdentifier(),
          undefined
        );
      } else if (node instanceof nodes.TypeDeclaration) {
        const dataType = node.getDataType();
        if (dataType instanceof nodes.DataType) {
          collect(
            node.getName(),
            SymbolKind.Interface,
            node,
            node.getIdentifier(),
            undefined
          );
        } else if (dataType instanceof nodes.EnumDataType) {
          collect(
            node.getName(),
            SymbolKind.Enum,
            node,
            node.getIdentifier(),
            dataType.getDeclarations()
          );
        } else if (dataType instanceof nodes.StructUnionDataType) {
          collect(
            node.getName(),
            SymbolKind.Struct,
            node,
            node.getIdentifier(),
            dataType.getDeclarations()
          );
        }
      } else if (node instanceof nodes.EnumNameDeclaration) {
        collect(
          node.getName(),
          SymbolKind.EnumMember,
          node,
          node.getIdentifier(),
          undefined
        );
      } else if (node instanceof nodes.AnsiPortDeclaration) {
        collect(
          node.getName(),
          SymbolKind.Variable,
          node,
          node.getIdentifier(),
          undefined
        );
      }

      return true;
    });
  }
}

function getRange(node: nodes.Node, document: TextDocument): Range {
  return Range.create(
    document.positionAt(node.offset),
    document.positionAt(node.end)
  );
}

function containsRange(range: Range, otherRange: Range): boolean {
  const otherStartLine = otherRange.start.line,
    otherEndLine = otherRange.end.line;
  const rangeStartLine = range.start.line,
    rangeEndLine = range.end.line;

  if (otherStartLine < rangeStartLine || otherEndLine < rangeStartLine) {
    return false;
  }
  if (otherStartLine > rangeEndLine || otherEndLine > rangeEndLine) {
    return false;
  }
  if (
    otherStartLine === rangeStartLine &&
    otherRange.start.character < range.start.character
  ) {
    return false;
  }
  if (
    otherEndLine === rangeEndLine &&
    otherRange.end.character > range.end.character
  ) {
    return false;
  }
  return true;
}

function getHighlightKind(node: nodes.Node): DocumentHighlightKind {
  if (node.parent) {
    switch (node.parent.type) {
      case nodes.NodeType.ModuleDeclaration:
        return DocumentHighlightKind.Write;
    }
  }

  return DocumentHighlightKind.Read;
}
