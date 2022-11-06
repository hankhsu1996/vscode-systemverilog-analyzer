import * as nodes from "./nodes";

export class IssueType implements nodes.IRule {
  id: string;
  message: string;

  public constructor(id: string, message: string) {
    this.id = id;
    this.message = message;
  }
}

export const ParseError = {};
