import { Parser } from "../parser/parser";
import { TextDocument } from "../languageTypes";
import * as nodes from "../parser/nodes";
import { ConsoleErrorListener } from "antlr4ts";

describe("Parser", () => {
  const parser = new Parser();

  test("it should parse an empty module", () => {
    const textDocument = TextDocument.create(
      "file:///test.sv",
      "systemverilog",
      0,
      `
      module my_module;
      endmodule
      `
    );
    const sourceText = parser.parseSourceText(textDocument);
    const module = sourceText.getChild(0) as nodes.ModuleDeclaration;
    expect(module.getName()).toBe("my_module");
  });

  test("it should parse an empty package", () => {
    const textDocument = TextDocument.create(
      "file:///test.sv",
      "systemverilog",
      0,
      `
      package my_package;
      endpackage
      `
    );
    const sourceText = parser.parseSourceText(textDocument);
    const pkg = sourceText.getChild(0) as nodes.PackageDeclaration;
    expect(pkg.getName()).toBe("my_package");
  });

  test("it should parse a module with parameters", () => {
    const textDocument = TextDocument.create(
      "file:///test.sv",
      "systemverilog",
      0,
      `
      module my_module;
        parameter  SOME_VAL1 = 1;
        localparam SOME_VAL2 = 2;
      endmodule
      `
    );
    const sourceText = parser.parseSourceText(textDocument);
    const module = sourceText.getChild(0) as nodes.ModuleDeclaration;
    expect(module.getName()).toBe("my_module");

    const moduleBody = module.getDeclarations() || [];
    const parameterDecl = moduleBody[0].getChild(
      0
    ) as nodes.ParameterDeclaration;

    const paramaterAssign = parameterDecl.getChild(0) as nodes.ParamAssignment;
    expect(paramaterAssign.getName()).toBe("SOME_VAL1");

    const localparamDecl = moduleBody[0].getChild(
      1
    ) as nodes.LocalParameterDeclaration;
    const localparamAssign = localparamDecl.getChild(
      0
    ) as nodes.ParamAssignment;
    expect(localparamAssign.getName()).toBe("SOME_VAL2");
  });

  test("it should parse a module with variable and net declarations", () => {
    const textDocument = TextDocument.create(
      "file:///test.sv",
      "systemverilog",
      0,
      `
      module my_module;
        var my_type my_variable = 1;
        logic my_net;
      endmodule
      `
    );
    const sourceText = parser.parseSourceText(textDocument);
    const module = sourceText.getChild(0) as nodes.ModuleDeclaration;
    expect(module.getName()).toBe("my_module");

    const moduleBody = module.getDeclarations() || [];
    expect(moduleBody).not.toBeNull();

    const variableDecl = moduleBody[0].getChild(0) as nodes.VariableDeclaration;
    expect(variableDecl).not.toBeNull();

    const variableAssign = variableDecl.getChild(
      0
    ) as nodes.VariableDeclAssignment;
    expect(variableAssign.getName()).toBe("my_variable");

    const netDecl = moduleBody[0].getChild(1) as nodes.NetDeclaration;
    expect(netDecl).not.toBeNull();

    const netAssign = netDecl.getChild(0) as nodes.NetDeclAssignment;
    expect(netAssign.getName()).toBe("my_net");
  });

  test("it should parse a module with struct/enum typedef", () => {
    const textDocument = TextDocument.create(
      "file:///test.sv",
      "systemverilog",
      0,
      `
      module my_module;
        typedef logic [31:0] my_data_t;
        typedef enum {A, B} my_enum;
        typedef struct {logic a; logic b;} my_struct;
      endmodule
      `
    );
    const sourceText = parser.parseSourceText(textDocument);
    const module = sourceText.getChild(0) as nodes.ModuleDeclaration;
    expect(module.getName()).toBe("my_module");

    const moduleBody = module.getDeclarations() || [];

    // My custom data type
    const typeDecl0 = moduleBody[0].getChild(0) as nodes.TypeDeclaration;
    expect(typeDecl0.getName()).toBe("my_data_t");

    // Enum
    const typeDecl1 = moduleBody[0].getChild(1) as nodes.TypeDeclaration;
    expect(typeDecl1.getName()).toBe("my_enum");

    const dataType1 = typeDecl1.getDataType() as nodes.EnumDataType;
    expect(dataType1?.type).toBe(nodes.NodeType.EnumDataType);

    const enumDecl1 = (dataType1?.getDeclarations() ||
      [])[0] as nodes.Declarations;

    const enumMember0 = enumDecl1.getChild(0) as nodes.EnumNameDeclaration;
    expect(enumMember0.getName()).toBe("A");

    const enumMember1 = enumDecl1.getChild(1) as nodes.EnumNameDeclaration;
    expect(enumMember1.getName()).toBe("B");

    // Struct
    const typeDecl2 = moduleBody[0].getChild(2) as nodes.TypeDeclaration;
    expect(typeDecl2.getName()).toBe("my_struct");

    const dataType2 = typeDecl2.getDataType() as nodes.StructUnionDataType;
    expect(dataType2?.type).toBe(nodes.NodeType.StructUnionDataType);

    const structDecl2 = (dataType2?.getDeclarations() ||
      [])[0] as nodes.Declarations;

    const structMember0 = structDecl2
      .getChild(0)
      ?.getChild(0) as nodes.VariableDeclAssignment;
    expect(structMember0.getName()).toBe("a");

    const structMember1 = structDecl2
      .getChild(1)
      ?.getChild(0) as nodes.VariableDeclAssignment;
    expect(structMember1.getName()).toBe("b");
  });

  test("it should parse a module with parameter port list and port list", () => {
    const textDocument = TextDocument.create(
      "file:///test.sv",
      "systemverilog",
      0,
      `
      module my_module
      #(
        parameter  SOME_VAL1 = 1,
        localparam SOME_VAL2 = 2
      ) (
        input  logic my_input,
        output logic my_output
      );
      endmodule
      `
    );
    const sourceText = parser.parseSourceText(textDocument);
    const module = sourceText.getChild(0) as nodes.ModuleDeclaration;
    expect(module.getName()).toBe("my_module");

    const moduleDecls = module.getDeclarations() || [];
    const parameterPortList = moduleDecls[0] as nodes.Declarations;
    const parameterPortDeclaration = parameterPortList.getChildren();

    const parameterDecl0 = parameterPortDeclaration[0].getChild(
      0
    ) as nodes.ParamAssignment;
    const localparamDecl1 = parameterPortDeclaration[1].getChild(
      0
    ) as nodes.ParamAssignment;
    expect(parameterDecl0.getName()).toBe("SOME_VAL1");
    expect(localparamDecl1.getName()).toBe("SOME_VAL2");

    const portList = moduleDecls[1] as nodes.Declarations;
    const portDeclaration = portList.getChildren();
    const inputDecl = portDeclaration[0].getChild(
      0
    ) as nodes.AnsiPortDeclaration;
    const outputDecl = portDeclaration[1].getChild(
      0
    ) as nodes.AnsiPortDeclaration;
    expect(inputDecl.getName()).toBe("my_input");
    expect(outputDecl.getName()).toBe("my_output");
  });
});
