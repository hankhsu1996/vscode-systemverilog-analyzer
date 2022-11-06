import { Parser } from "../parser/parser";
import { TextDocument } from "../languageTypes";
import { Navigation } from "../services/navigation";
import * as nodes from "../parser/nodes";
import { SymbolKind } from "../languageTypes";

describe("Navigation", () => {
  const parser = new Parser();
  const navigation = new Navigation();

  test("it should get the symbol of a module", () => {
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
    const symbols = navigation.findDocumentSymbols(textDocument, sourceText);
    expect(symbols).toMatchObject([
      {
        name: "my_module",
        kind: SymbolKind.Class,
      },
    ]);
  });

  test("it should get the symbol of a package", () => {
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
    const symbols = navigation.findDocumentSymbols(textDocument, sourceText);
    expect(symbols).toMatchObject([
      {
        name: "my_package",
        kind: SymbolKind.Package,
      },
    ]);
  });

  test("it should get the parameter and localparam symbols in the module", () => {
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
    const symbols = navigation.findDocumentSymbols(textDocument, sourceText);
    expect(symbols).toMatchObject([
      {
        name: "my_module",
        kind: SymbolKind.Class,
        children: [
          {
            name: "SOME_VAL1",
            kind: SymbolKind.Variable,
          },
          {
            name: "SOME_VAL2",
            kind: SymbolKind.Variable,
          },
        ],
      },
    ]);
  });

  test("it should get the variable and net symbols in the module", () => {
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
    const symbols = navigation.findDocumentSymbols(textDocument, sourceText);
    expect(symbols).toMatchObject([
      {
        name: "my_module",
        kind: SymbolKind.Class,
        children: [
          {
            name: "my_variable",
            kind: SymbolKind.Variable,
          },
          {
            name: "my_net",
            kind: SymbolKind.Variable,
          },
        ],
      },
    ]);
  });

  test("it should get the enum and struct typedef symbols in the module", () => {
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
    const symbols = navigation.findDocumentSymbols(textDocument, sourceText);
    expect(symbols).toEqual(
      expect.arrayContaining([
        expect.objectContaining({
          name: "my_module",
          kind: SymbolKind.Class,
          children: expect.arrayContaining([
            expect.objectContaining({
              name: "my_data_t",
              kind: SymbolKind.Interface,
            }),
            expect.objectContaining({
              name: "my_enum",
              kind: SymbolKind.Enum,
              children: expect.arrayContaining([
                expect.objectContaining({
                  name: "A",
                  kind: SymbolKind.EnumMember,
                }),
                expect.objectContaining({
                  name: "B",
                  kind: SymbolKind.EnumMember,
                }),
              ]),
            }),
            expect.objectContaining({
              name: "my_struct",
              kind: SymbolKind.Struct,
              children: expect.arrayContaining([
                expect.objectContaining({
                  name: "a",
                  kind: SymbolKind.Field,
                }),
                expect.objectContaining({
                  name: "b",
                  kind: SymbolKind.Field,
                }),
              ]),
            }),
          ]),
        }),
      ])
    );
  });

  test("it should get parameter port list and port list symbols in a module", () => {
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
    const symbols = navigation.findDocumentSymbols(textDocument, sourceText);
    expect(symbols).toEqual(
      expect.arrayContaining([
        expect.objectContaining({
          name: "my_module",
          kind: SymbolKind.Class,
          children: expect.arrayContaining([
            expect.objectContaining({
              name: "SOME_VAL1",
              kind: SymbolKind.Variable,
            }),
            expect.objectContaining({
              name: "SOME_VAL2",
              kind: SymbolKind.Variable,
            }),
            expect.objectContaining({
              name: "my_input",
              kind: SymbolKind.Variable,
            }),
            expect.objectContaining({
              name: "my_output",
              kind: SymbolKind.Variable,
            }),
          ]),
        }),
      ])
    );
  });
});
