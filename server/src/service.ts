import {
  Position,
  Location,
  SymbolInformation,
  TextDocument,
  DocumentSymbol,
} from "./languageTypes";
import { Parser } from "./parser/parser";
import * as nodes from "./parser/nodes";
import { Navigation } from "./services/navigation";

export type SourceText = unknown;
export * from "./languageTypes";

export interface LanguageService {
  parseSourceText(document: TextDocument): nodes.SourceText;
  findDefinition(
    document: TextDocument,
    position: Position,
    sourceText: SourceText
  ): Location | null;
  findDocumentSymbols(
    document: TextDocument,
    sourceText: SourceText
  ): SymbolInformation[];

  findDocumentSymbols2(
    document: TextDocument,
    sourceText: SourceText
  ): DocumentSymbol[];
}

export function getLanguageService(): LanguageService {
  const parser = new Parser();
  const navigation = new Navigation();
  return {
    parseSourceText: parser.parseSourceText.bind(parser),
    findDefinition: navigation.findDefinition.bind(navigation),
    findDocumentSymbols: navigation.findSymbolInformations.bind(navigation),
    findDocumentSymbols2: navigation.findDocumentSymbols.bind(navigation),
  };
}
