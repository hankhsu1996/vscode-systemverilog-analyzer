import { TextDocument } from "../languageTypes";
import { CharStreams, CommonTokenStream, ParserRuleContext } from "antlr4ts";
import { SystemVerilog2017Lexer } from "../grammars/SystemVerilog2017Lexer";
import {
  AnsiPortDeclarationContext,
  ConstantParamExpressionContext,
  DataDeclarationContext,
  DataTypeContext,
  DescriptionContext,
  EnumBodyContext,
  EnumNameDeclarationContext,
  ExpressionContext,
  FunctionDeclarationContext,
  IdentifierContext,
  ListOfPortDeclarationsContext,
  LocalParameterDeclarationContext,
  ModuleDeclarationBodyContext,
  ModuleDeclarationContext,
  ModuleItemContext,
  ModuleOrGenerateOrInterfaceItemContext,
  NetDeclarationContext,
  NetDeclAssignmentContext,
  PackageDeclarationBodyContext,
  PackageDeclarationContext,
  PackageItemContext,
  ParamAssignmentContext,
  ParameterDeclarationContext,
  ParameterPortListContext,
  SourceTextContext,
  StructUnionBodyContext,
  StructUnionMemberContext,
  SystemVerilog2017Parser,
  TaskDeclarationContext,
  TypeDeclarationContext,
  VariableDeclAssignmentContext,
} from "../grammars/SystemVerilog2017Parser";
import * as nodes from "./nodes";
import { AbstractParseTreeVisitor } from "antlr4ts/tree/AbstractParseTreeVisitor";
import { SystemVerilog2017ParserVisitor } from "../grammars/SystemVerilog2017ParserVisitor";
import { exit } from "process";

export class Parser
  extends AbstractParseTreeVisitor<nodes.Node | null>
  implements SystemVerilog2017ParserVisitor<nodes.Node | null>
{
  public parseSourceText(textDocument: TextDocument): nodes.SourceText {
    const versionId = textDocument.version;
    const text = textDocument.getText();
    const textProvider = (offset: number, length: number) => {
      if (textDocument.version !== versionId) {
        throw new Error("Underlying model has changed, AST is no longer valid");
      }
      return text.substring(offset, offset + length);
    };

    // Link the textProvider in SourceTextVisitor to here

    const inputStream = new (CharStreams as any).fromString(text);
    const lexer = new SystemVerilog2017Lexer(inputStream);
    const tokenStream = new CommonTokenStream(lexer);
    const parser = new SystemVerilog2017Parser(tokenStream);
    const tree = parser.sourceText();

    const node = this.visitSourceText(tree);

    if (node) {
      node.textProvider = textProvider;
    }
    // return this.create(tree, nodes.SourceText);
    return node;
  }

  public create<T>(ctx: ParserRuleContext, ctor: nodes.NodeConstructor<T>): T {
    const offset = ctx.start.startIndex;
    const len = ctx.stop ? ctx.stop.stopIndex - ctx.start.startIndex + 1 : 0;
    return new ctor(offset, len);
  }

  public finish<T extends nodes.Node>(node: T): T {
    // Currenyly, this is a no-op
    return node;
  }

  protected defaultResult(): nodes.SourceText {
    throw new Error("Method not implemented.");
  }

  public visitSourceText(ctx: SourceTextContext): nodes.SourceText {
    const node = this.create(ctx, nodes.SourceText);
    const descriptionsCtx = ctx.description();
    for (const descriptionCtx of descriptionsCtx) {
      const description = this.visitDescription(descriptionCtx);
      if (description) {
        node.addChild(description);
      }
    }
    return node;
  }

  public visitDescription(ctx: DescriptionContext): nodes.Node | null {
    const moduleDeclarationCtx = ctx.moduleDeclaration();
    const packageDeclarationCtx = ctx.packageDeclaration();

    return (
      (moduleDeclarationCtx &&
        this.visitModuleDeclaration(moduleDeclarationCtx)) ||
      (packageDeclarationCtx &&
        this.visitPackageDeclaration(packageDeclarationCtx)) ||
      null
    );
  }

  public visitModuleDeclaration(
    ctx: ModuleDeclarationContext
  ): nodes.Node | null {
    const node = this.create(ctx, nodes.ModuleDeclaration);

    const moduleKeywordCtx = ctx.moduleHeaderCommon().moduleKeyword();
    const moduleKeyword = this.create(moduleKeywordCtx, nodes.Node);
    node.setModuleKeyword(moduleKeyword);

    const identifierCtx = ctx.moduleHeaderCommon().identifier();
    const identifier = this.visitIdentifier(identifierCtx);
    node.setIdentifier(identifier);

    // TODO packageImportDeclaration
    const parameterPortListCtx = ctx.moduleHeaderCommon().parameterPortList();
    if (parameterPortListCtx) {
      const parameterPortList =
        this.visitParameterPortList(parameterPortListCtx);
      node.pushDeclarations(parameterPortList);
    }

    const listOfPortDeclarationsCtx = ctx.listOfPortDeclarations();
    if (listOfPortDeclarationsCtx) {
      const listOfPortDeclarations = this.visitListOfPortDeclarations(
        listOfPortDeclarationsCtx
      );
      node.pushDeclarations(listOfPortDeclarations);
    }

    const moduleDeclarationBodyCtx = ctx.moduleDeclarationBody();
    if (!moduleDeclarationBodyCtx) {
      return null;
    }
    const moduleDeclarationBody = this.visitModuleDeclarationBody(
      moduleDeclarationBodyCtx
    );
    if (moduleDeclarationBody) {
      node.pushDeclarations(moduleDeclarationBody);
    }

    return this.finish(node);
  }

  public visitParameterPortList(
    ctx: ParameterPortListContext
  ): nodes.Declarations | null {
    const node = this.create(ctx, nodes.Declarations);

    const parameterPortDeclarationsCtx = ctx.parameterPortDeclaration();

    for (const parameterPortDeclarationCtx of parameterPortDeclarationsCtx) {
      const parameterDeclarationCtx =
        parameterPortDeclarationCtx.parameterDeclaration();
      const localParameterDeclarationCtx =
        parameterPortDeclarationCtx.localParameterDeclaration();
      const listOfParamAssignmentsCtx =
        parameterPortDeclarationCtx.listOfParamAssignments();

      if (parameterPortDeclarationCtx.KW_TYPE()) {
        // TODO
      } else if (parameterDeclarationCtx) {
        const parameterDeclaration = this.visitParameterDeclaration(
          parameterDeclarationCtx
        );
        if (parameterDeclaration) {
          node.addChild(parameterDeclaration);
        }
      } else if (localParameterDeclarationCtx) {
        const localParameterDeclaration = this.visitLocalParameterDeclaration(
          localParameterDeclarationCtx
        );
        if (localParameterDeclaration) {
          node.addChild(localParameterDeclaration);
        }
      } else if (listOfParamAssignmentsCtx) {
        // TODO
      }
    }

    return this.finish(node);
  }

  public visitListOfPortDeclarations(
    ctx: ListOfPortDeclarationsContext
  ): nodes.Declarations | null {
    const node = this.create(ctx, nodes.Declarations);

    // TODO nonansiPort

    const listOfPortDeclarationsAnsiItemCtx =
      ctx.listOfPortDeclarationsAnsiItem();
    for (const listOfPortDeclarationsAnsiItem of listOfPortDeclarationsAnsiItemCtx) {
      const ansiPortDeclarationCtx =
        listOfPortDeclarationsAnsiItem.ansiPortDeclaration();
      const ansiPortDeclaration = this.visitAnsiPortDeclaration(
        ansiPortDeclarationCtx
      );
      if (ansiPortDeclaration) {
        node.addChild(ansiPortDeclaration);
      }
    }

    return this.finish(node);
  }

  public visitAnsiPortDeclaration(
    ctx: AnsiPortDeclarationContext
  ): nodes.Node | null {
    const node = this.create(ctx, nodes.AnsiPortDeclaration);
    // TODO portDirection

    if (!ctx.DOT()) {
      const identifierCtx = ctx.portIdentifier().identifier();
      const identifier = this.visitIdentifier(identifierCtx);
      node.setIdentifier(identifier);
    }

    // TODO netOrVarDataType
    // TODO constantExpression
    return this.finish(node);
  }

  public visitModuleDeclarationBody(
    ctx: ModuleDeclarationBodyContext
  ): nodes.Declarations | null {
    const node = this.create(ctx, nodes.Declarations);

    const moduleitemsCtx = ctx.moduleItem();
    for (const moduleItemCtx of moduleitemsCtx) {
      // TODO: Module item hierarchy is complicated. Only support a few cases for now.
      // moduleItem -> moduleItemItem -> moduleOrGenerateItem -> moduleOrGenerateOrInterfaceItem
      const moduleOrGenerateOrInterfaceItemCtx = moduleItemCtx
        .moduleItemItem()
        ?.moduleOrGenerateItem()
        ?.moduleOrGenerateOrInterfaceItem();

      if (!moduleOrGenerateOrInterfaceItemCtx) {
        continue;
      }

      const moduleItem = this.visitModuleOrGenerateOrInterfaceItem(
        moduleOrGenerateOrInterfaceItemCtx
      );
      if (moduleItem) {
        node.addChild(moduleItem);
      }
    }

    return this.finish(node);
  }

  public visitModuleOrGenerateOrInterfaceItem(
    ctx: ModuleOrGenerateOrInterfaceItemContext
  ): nodes.Node | null {
    // TODO moduleOrInterfaceOrProgramOrUdpInstantiation
    // TODO defaultClockingOrDissableConstruct
    const localParameterDeclarationCtx = ctx.localParameterDeclaration();
    const parameterDeclarationCtx = ctx.parameterDeclaration();
    const netDeclarationCtx = ctx.netDeclaration();
    const dataDeclarationCtx = ctx.dataDeclaration();
    const taskDeclarationCtx = ctx.taskDeclaration();
    // TODO moduleOrGenerateOrInterfaceOrCheckerItem
    // TODO dpiImportExport
    // TODO externConstraintDeclaration
    // TODO classDeclaration
    // TODO interfaceClassDeclaration
    // TODO classConstructorDeclaration
    // TODO bindDirective
    // TODO netAlias
    // TODO loopGenerateConstruct
    // TODO conditionalGenerateConstruct
    // TODO elaborationSystemTask

    return (
      (localParameterDeclarationCtx &&
        this.visitLocalParameterDeclaration(localParameterDeclarationCtx)) ||
      (parameterDeclarationCtx &&
        this.visitParameterDeclaration(parameterDeclarationCtx)) ||
      (netDeclarationCtx && this.visitNetDeclaration(netDeclarationCtx)) ||
      (dataDeclarationCtx && this.visitDataDeclaration(dataDeclarationCtx)) ||
      (taskDeclarationCtx && this.visitTaskDeclaration(taskDeclarationCtx)) ||
      null
    );
  }

  public visitPackageDeclaration(
    ctx: PackageDeclarationContext
  ): nodes.Node | null {
    const node = this.create(ctx, nodes.PackageDeclaration);

    const identifierCtx = ctx.identifier()[0];
    const identifier = this.visitIdentifier(identifierCtx);
    node.setIdentifier(identifier);

    const packageDeclarationBodyCtx = ctx.packageDeclarationBody();
    const packageDeclarationBody = this.visitPackageDeclarationBody(
      packageDeclarationBodyCtx
    );
    node.pushDeclarations(packageDeclarationBody);

    return this.finish(node);
  }

  public visitPackageDeclarationBody(
    ctx: PackageDeclarationBodyContext
  ): nodes.Declarations | null {
    const node = this.create(ctx, nodes.Declarations);

    const packageItemsCtx = ctx.packageItem();
    for (const packageItemCtx of packageItemsCtx) {
      const packageItem = this.visitPackageItem(packageItemCtx);
      if (packageItem) {
        node.addChild(packageItem);
      }
    }
    return this.finish(node);
  }

  public visitPackageItem(ctx: PackageItemContext): nodes.Node | null {
    // TODO netDeclaration
    const dataDeclarationCtx = ctx.dataDeclaration();
    const taskDeclarationCtx = ctx.taskDeclaration();
    const functionDeclarationCtx = ctx.functionDeclaration();
    // TODO checkerDeclaration
    // TODO dpiImportExport
    // TODO externConstraintDeclaration
    // TODO classDeclaration
    // TODO classConstructorDeclaration
    // TODO classConstraintDeclaration
    const localParameterDeclarationCtx = ctx.localParameterDeclaration();
    const parameterDeclarationCtx = ctx.parameterDeclaration();
    // TODO covergroupDeclaration
    // TODO propertyDeclaration
    // TODO sequenceDeclaration
    // TODO letDeclaration
    // TODO anonymousProgram
    // TODO packageExportDeclaration
    // TODO timeunitsDeclaration

    return (
      (dataDeclarationCtx && this.visitDataDeclaration(dataDeclarationCtx)) ||
      (taskDeclarationCtx && this.visitTaskDeclaration(taskDeclarationCtx)) ||
      (functionDeclarationCtx &&
        this.visitFunctionDeclaration(functionDeclarationCtx)) ||
      (localParameterDeclarationCtx &&
        this.visitLocalParameterDeclaration(localParameterDeclarationCtx)) ||
      (parameterDeclarationCtx &&
        this.visitParameterDeclaration(parameterDeclarationCtx)) ||
      null
    );
  }

  public visitFunctionDeclaration(
    ctx: FunctionDeclarationContext
  ): nodes.Node | null {
    const node = this.create(ctx, nodes.FunctionDeclaration);

    const identifierCtx = ctx.taskAndFunctionDeclarationCommon().identifier();
    const identifier = this.visitIdentifier(
      identifierCtx[identifierCtx.length - 1]
    );
    node.setIdentifier(identifier);

    return this.finish(node);
  }

  public visitTaskDeclaration(ctx: TaskDeclarationContext): nodes.Node | null {
    const node = this.create(ctx, nodes.TaskDeclaration);

    const identifierCtx = ctx.taskAndFunctionDeclarationCommon().identifier();
    const identifier = this.visitIdentifier(
      identifierCtx[identifierCtx.length - 1]
    );
    node.setIdentifier(identifier);

    return this.finish(node);
  }

  public visitParameterDeclaration(
    ctx: ParameterDeclarationContext
  ): nodes.Node | null {
    const node = this.create(ctx, nodes.ParameterDeclaration);

    // TODO dataTypeOrImplicit

    const listOfParamAssignmentsCtx = ctx.listOfParamAssignments();
    if (!listOfParamAssignmentsCtx) {
      return this.finish(node);
    }

    const paramAssignmentsCtx = listOfParamAssignmentsCtx.paramAssignment();
    for (const paramAssignmentCtx of paramAssignmentsCtx) {
      const paramAssignment = this.visitParamAssignment(paramAssignmentCtx);
      if (paramAssignment) {
        node.addChild(paramAssignment);
      }
    }

    return this.finish(node);
  }

  public visitLocalParameterDeclaration(
    ctx: LocalParameterDeclarationContext
  ): nodes.Node | null {
    const node = this.create(ctx, nodes.LocalParameterDeclaration);

    // TODO dataTypeOrImplicit

    const listOfParamAssignmentsCtx = ctx.listOfParamAssignments();
    if (!listOfParamAssignmentsCtx) {
      return this.finish(node);
    }

    const paramAssignmentsCtx = listOfParamAssignmentsCtx.paramAssignment();
    for (const paramAssignmentCtx of paramAssignmentsCtx) {
      const paramAssignment = this.visitParamAssignment(paramAssignmentCtx);
      if (paramAssignment) {
        node.addChild(paramAssignment);
      }
    }

    return this.finish(node);
  }

  public visitParamAssignment(ctx: ParamAssignmentContext): nodes.Node | null {
    const node = this.create(ctx, nodes.ParamAssignment);

    const identifierCtx = ctx.identifier();
    if (!node.setIdentifier(this.visitIdentifier(identifierCtx))) {
      return null;
    }

    // TODO unpackedDimension

    const constantParamExpressionCtx = ctx.constantParamExpression();
    if (!constantParamExpressionCtx) {
      return this.finish(node);
    }

    if (
      !node.setValue(
        this.visitConstantParamExpression(constantParamExpressionCtx)
      )
    ) {
      return this.finish(node);
    }

    return this.finish(node);
  }

  public visitNetDeclaration(ctx: NetDeclarationContext): nodes.Node | null {
    const node = this.create(ctx, nodes.NetDeclaration);

    // TODO netType
    // TODO driveStrength chargeStrength
    // TODO dataTypeOrImplicit

    const listOfNetDeclAssignmentsCtx = ctx.listOfNetDeclAssignments();
    if (!listOfNetDeclAssignmentsCtx) {
      return this.finish(node);
    }

    const netDeclAssignmentCtx =
      listOfNetDeclAssignmentsCtx.netDeclAssignment();
    for (const netDeclAssignment of netDeclAssignmentCtx) {
      const netDeclAssignmentNode =
        this.visitNetDeclAssignment(netDeclAssignment);
      if (netDeclAssignmentNode) {
        node.addChild(netDeclAssignmentNode);
      }
    }

    return this.finish(node);
  }

  public visitNetDeclAssignment(
    ctx: NetDeclAssignmentContext
  ): nodes.Node | null {
    const node = this.create(ctx, nodes.NetDeclAssignment);

    const identifierCtx = ctx.identifier();
    if (!node.setIdentifier(this.visitIdentifier(identifierCtx))) {
      return null;
    }

    // TODO unpackedDimension

    const expressionCtx = ctx.expression();
    if (!expressionCtx) {
      return this.finish(node);
    }

    if (!node.setValue(this.visitExpression(expressionCtx))) {
      return this.finish(node);
    }

    return this.finish(node);
  }

  public visitDataDeclaration(ctx: DataDeclarationContext): nodes.Node | null {
    const typeDeclarationCtx = ctx.typeDeclaration();
    const packageImportDeclarationCtx = ctx.packageImportDeclaration();
    const netTypeDeclarationCtx = ctx.netTypeDeclaration();

    if (typeDeclarationCtx) {
      return this.visitTypeDeclaration(typeDeclarationCtx);
    } else if (packageImportDeclarationCtx) {
      return null;
    } else if (netTypeDeclarationCtx) {
      return null;
    } else {
      const node = this.create(ctx, nodes.VariableDeclaration);

      // TODO dataTypeOrImplicit

      const listOfVariableDeclAssignmentsCtx =
        ctx.listOfVariableDeclAssignments();
      if (!listOfVariableDeclAssignmentsCtx) {
        return this.finish(node);
      }

      const variableDeclAssignmentsCtx =
        listOfVariableDeclAssignmentsCtx.variableDeclAssignment();
      for (const variableDeclAssignmentCtx of variableDeclAssignmentsCtx) {
        const variableDeclAssignment = this.visitVariableDeclAssignment(
          variableDeclAssignmentCtx
        );
        if (variableDeclAssignment) {
          node.addChild(variableDeclAssignment);
        }
      }
      return this.finish(node);
    }
  }

  public visitTypeDeclaration(ctx: TypeDeclarationContext): nodes.Node | null {
    const node = this.create(ctx, nodes.TypeDeclaration);

    const dataTypeCtx = ctx.dataType();
    if (dataTypeCtx) {
      const identifierCtx = ctx.identifier()[0];
      if (!node.setIdentifier(this.visitIdentifier(identifierCtx))) {
        return null;
      }

      if (!node.setDataType(this.visitDataType(dataTypeCtx))) {
        return null;
      }
    }
    return this.finish(node);
  }

  public visitDataType(ctx: DataTypeContext): nodes.Node | null {
    if (ctx.KW_STRING()) {
      return this.create(ctx, nodes.DataType);
    } else if (ctx.KW_CHANDLE()) {
      return this.create(ctx, nodes.DataType);
    } else if (ctx.KW_VIRTUAL()) {
      return this.create(ctx, nodes.DataType);
    } else if (ctx.KW_EVENT()) {
      return this.create(ctx, nodes.DataType);
    } else if (ctx.dataTypePrimitive()) {
      return this.create(ctx, nodes.DataType);
    } else if (ctx.KW_ENUM()) {
      const node = this.create(ctx, nodes.EnumDataType);

      // TODO baseType

      const enumBodyCtx = ctx.enumBody();
      if (!enumBodyCtx) {
        return this.finish(node);
      }
      const enumBody = this.visitEnumBody(enumBodyCtx);
      if (!enumBody) {
        return this.finish(node);
      }
      node.pushDeclarations(enumBody);
      return this.finish(node);
    } else if (ctx.structUnion()) {
      const node = this.create(ctx, nodes.StructUnionDataType);
      const structUnionBody = ctx.structUnionBody();
      if (!structUnionBody) {
        return this.finish(node);
      }
      const structUnionBodyNode = this.visitStructUnionBody(structUnionBody);
      if (!structUnionBodyNode) {
        return this.finish(node);
      }
      node.pushDeclarations(structUnionBodyNode);
      return this.finish(node);
    } else if (ctx.packageOrClassScopedPath()) {
      return this.create(ctx, nodes.DataType);
    } else if (ctx.typeReference()) {
      return this.create(ctx, nodes.DataType);
    }

    return null;
  }

  public visitEnumBody(ctx: EnumBodyContext): nodes.Declarations | null {
    const node = this.create(ctx, nodes.Declarations);

    const enumNameDeclarationsCtx = ctx.enumNameDeclaration();
    for (const enumNameDeclarationCtx of enumNameDeclarationsCtx) {
      const enumNameDeclaration = this.visitEnumNameDeclaration(
        enumNameDeclarationCtx
      );
      if (enumNameDeclaration) {
        node.addChild(enumNameDeclaration);
      }
    }
    return this.finish(node);
  }

  public visitEnumNameDeclaration(
    ctx: EnumNameDeclarationContext
  ): nodes.Node | null {
    const node = this.create(ctx, nodes.EnumNameDeclaration);

    const identifierCtx = ctx.identifier();
    if (!node.setIdentifier(this.visitIdentifier(identifierCtx))) {
      return null;
    }

    const expressionCtx = ctx.expression();
    if (!expressionCtx) {
      return this.finish(node);
    }

    if (!node.setValue(this.visitExpression(expressionCtx))) {
      return this.finish(node);
    }

    return this.finish(node);
  }

  visitStructUnionBody(ctx: StructUnionBodyContext): nodes.Declarations | null {
    const node = this.create(ctx, nodes.Declarations);
    const structUnionMembersCtx = ctx.structUnionMember();
    for (const structUnionMemberCtx of structUnionMembersCtx) {
      const structUnionMember =
        this.visitStructUnionMember(structUnionMemberCtx);
      if (structUnionMember) {
        node.addChild(structUnionMember);
      }
    }
    return this.finish(node);
  }

  visitStructUnionMember(ctx: StructUnionMemberContext): nodes.Node | null {
    const node = this.create(ctx, nodes.StructUnionMember);

    // TODO dataTypeOrVoid

    const listOfVariableDeclAssignmentsCtx =
      ctx.listOfVariableDeclAssignments();
    if (!listOfVariableDeclAssignmentsCtx) {
      return this.finish(node);
    }

    const variableDeclAssignmentsCtx =
      listOfVariableDeclAssignmentsCtx.variableDeclAssignment();
    for (const variableDeclAssignmentCtx of variableDeclAssignmentsCtx) {
      const variableDeclAssignment = this.visitVariableDeclAssignment(
        variableDeclAssignmentCtx
      );
      if (variableDeclAssignment) {
        node.addChild(variableDeclAssignment);
      }
    }

    return this.finish(node);
  }

  public visitVariableDeclAssignment(
    ctx: VariableDeclAssignmentContext
  ): nodes.Node | null {
    const node = this.create(ctx, nodes.VariableDeclAssignment);

    const identifierCtx = ctx.identifier();
    if (!node.setIdentifier(this.visitIdentifier(identifierCtx))) {
      return null;
    }

    // TODO variableDimension

    const expressionCtx = ctx.expression();
    if (!expressionCtx) {
      return this.finish(node);
    }

    if (!node.setValue(this.visitExpression(expressionCtx))) {
      return this.finish(node);
    }

    return this.finish(node);
  }

  public visitConstantParamExpression(
    ctx: ConstantParamExpressionContext
  ): nodes.ConstantParamExpression | null {
    const node = this.create(ctx, nodes.ConstantParamExpression);

    // TODO

    return this.finish(node);
  }

  public visitExpression(ctx: ExpressionContext): nodes.Expression | null {
    const node = this.create(ctx, nodes.Expression);

    // TODO

    return this.finish(node);
  }

  public visitIdentifier(ctx: IdentifierContext): nodes.Identifier | null {
    const node = this.create(ctx, nodes.Identifier);
    return this.finish(node);
  }
}
