import {
  createConnection,
  Connection,
  TextDocuments,
  InitializeParams,
  InitializeResult,
  WorkspaceFolder,
  ServerCapabilities,
  Disposable,
  TextDocumentSyncKind,
} from "vscode-languageserver/node";
import { LanguageSettings, SourceText, TextDocument } from "./service";
import { LanguageService, getLanguageService } from "./service";
import { getLanguageModelCache } from "./languageModelCache";
import { runSafeAsync } from "./utils/runner";
import { RequestService, getRequestService } from "./requests";
import { SourceTextContext } from "./grammars/SystemVerilog2017Parser";
import * as nodes from "./parser/nodes";

// Create a connection for the server.
const connection: Connection = createConnection();

console.log = connection.console.log.bind(connection.console);
console.error = connection.console.error.bind(connection.console);

const runtime: RuntimeEnvironment = {
  timer: {
    setImmediate(
      callback: (...args: any[]) => void,
      ...args: any[]
    ): Disposable {
      const handle = setImmediate(callback, ...args);
      return { dispose: () => clearImmediate(handle) };
    },
    setTimeout(
      callback: (...args: any[]) => void,
      ms: number,
      ...args: any[]
    ): Disposable {
      const handle = setTimeout(callback, ms, ...args);
      return { dispose: () => clearTimeout(handle) };
    },
  },
};

export interface RuntimeEnvironment {
  readonly file?: RequestService;
  readonly http?: RequestService;
  readonly timer: {
    setImmediate(
      callback: (...args: any[]) => void,
      ...args: any[]
    ): Disposable;
    setTimeout(
      callback: (...args: any[]) => void,
      ms: number,
      ...args: any[]
    ): Disposable;
  };
}

export function startServer(connection: Connection) {
  connection.console.log("Starting server");

  // Create a text document manager.
  const documents = new TextDocuments(TextDocument);
  // Make the text document manager listen on the connection
  // for open, change and close text document events
  documents.listen(connection);

  const sourceTexts = getLanguageModelCache<nodes.SourceText>(
    10,
    60,
    (document) => getLanguageService().parseSourceText(document)
  );
  documents.onDidClose((e) => {
    sourceTexts.onDocumentRemoved(e.document);
  });

  connection.onShutdown(() => {
    sourceTexts.dispose();
  });

  let workspaceFolders: WorkspaceFolder[];
  let languageService: LanguageService;
  const dataProvidersReady: Promise<any> = Promise.resolve();

  connection.onInitialize((params: InitializeParams): InitializeResult => {
    connection.console.log("Initializing server");

    const { initializationOptions } = params;

    // Get workspace folders
    workspaceFolders = params.workspaceFolders || [];

    // Get language service
    languageService = getLanguageService();

    const capabilities: ServerCapabilities = {
      textDocumentSync: TextDocumentSyncKind.Incremental,
      documentSymbolProvider: true,
      workspace: {
        workspaceFolders: {
          supported: true,
        },
      },
    };

    const result: InitializeResult = {
      capabilities,
    };

    return result;
  });

  connection.onDocumentSymbol((documentSymbolParams, token) => {
    console.log("Document symbol request received");

    return runSafeAsync(
      runtime,
      async () => {
        const document = documents.get(documentSymbolParams.textDocument.uri);
        if (document) {
          await dataProvidersReady;
          const sourceText = sourceTexts.get(document);
          return getLanguageService().findDocumentSymbols2(
            document,
            sourceText
          );
        }
        return [];
      },
      [],
      `Error while computing document symbols for ${documentSymbolParams.textDocument.uri}`,
      token
    );
  });

  documents.onDidChangeContent((change) => {
    console.log("Document change received");
    // log the file name
    console.log(change.document.uri);
  });

  connection.listen();
}

startServer(connection);
