export enum NodeType {
  Undefined,
  SourceText,
  ModuleDeclaration,
  AnsiPortDeclaration,
  PackageDeclaration,
  FunctionDeclaration,
  TaskDeclaration,
  ParameterDeclaration,
  LocalParameterDeclaration,
  ParamAssignment,
  Identifier,
  ParameterName,
  ConstantParamExpression,
  Declarations,
  TypeDeclaration,
  VariableDeclaration,
  VariableDeclAssignment,
  NetDeclaration,
  NetDeclAssignment,
  DataType,
  EnumDataType,
  EnumNameDeclaration,
  StructUnionDataType,
  StructUnionMember,
  Expression,
}

export enum ReferenceType {
  Package,
  Module,
  Interface,
  Program,
  Class,
  Function,
  Task,
  Variable,
  Net,
  Parameter,
  LocalParameter,
  Type,
}

export function getNodeAtOffset(node: Node, offset: number): Node | null {
  let candidate: Node | null = null;
  if (!node || offset < node.offset || offset > node.end) {
    return null;
  }

  // Find the shortest node at the position
  node.accept((node) => {
    if (node.offset === -1 && node.length === -1) {
      return true;
    }
    if (node.offset <= offset && node.end >= offset) {
      if (!candidate) {
        candidate = node;
      } else if (node.length <= candidate.length) {
        candidate = node;
      }
      return true;
    }
    return false;
  });
  return candidate;
}

export function getNodePath(node: Node, offset: number): Node[] {
  let candidate = getNodeAtOffset(node, offset);
  const path: Node[] = [];

  while (candidate) {
    path.unshift(candidate);
    candidate = candidate.parent;
  }

  return path;
}

export interface ITextProvider {
  (offset: number, length: number): string;
}

export class Node {
  public parent: Node | null;

  public offset: number;
  public length: number;
  public get end() {
    return this.offset + this.length;
  }

  public options: { [name: string]: any } | undefined;

  public textProvider: ITextProvider | undefined; // only set on the root node

  private children: Node[] | undefined;
  private issues: IMarker[] | undefined;

  private nodeType: NodeType | undefined;

  constructor(offset = -1, len = -1, nodeType?: NodeType) {
    this.parent = null;
    this.offset = offset;
    this.length = len;
    if (nodeType) {
      this.nodeType = nodeType;
    }
  }

  public set type(type: NodeType) {
    this.nodeType = type;
  }

  public get type(): NodeType {
    return this.nodeType || NodeType.Undefined;
  }

  private getTextProvider(): ITextProvider {
    // eslint-disable-next-line @typescript-eslint/no-this-alias
    let node: Node | null = this;
    while (node && !node.textProvider) {
      node = node.parent;
    }
    if (node) {
      return node.textProvider!;
    }
    return () => {
      return "unknown";
    };
  }

  public getText(): string {
    return this.getTextProvider()(this.offset, this.length);
  }

  public matches(str: string): boolean {
    return (
      this.length === str.length &&
      this.getTextProvider()(this.offset, this.length) === str
    );
  }

  public startsWith(str: string): boolean {
    return (
      this.length >= str.length &&
      this.getTextProvider()(this.offset, str.length) === str
    );
  }

  public endsWith(str: string): boolean {
    return (
      this.length >= str.length &&
      this.getTextProvider()(this.end - str.length, str.length) === str
    );
  }

  public accept(visitor: IVisitorFunction): void {
    if (visitor(this) && this.children) {
      for (const child of this.children) {
        child.accept(visitor);
      }
    }
  }

  public acceptVisitor(visitor: IVisitor): void {
    this.accept(visitor.visitNode.bind(visitor));
  }

  public adoptChild(node: Node, index = -1): Node {
    if (node.parent && node.parent.children) {
      const idx = node.parent.children.indexOf(node);
      if (idx >= 0) {
        node.parent.children.splice(idx, 1);
      }
    }
    node.parent = this;
    let children = this.children;
    if (!children) {
      children = this.children = [];
    }
    if (index !== -1) {
      children.splice(index, 0, node);
    } else {
      children.push(node);
    }
    return node;
  }

  public attachTo(parent: Node, index = -1): Node {
    if (parent) {
      parent.adoptChild(this, index);
    }
    return this;
  }

  public collectIssues(results: any[]): void {
    if (this.issues) {
      // eslint-disable-next-line prefer-spread
      results.push.apply(results, this.issues);
    }
  }

  public addIssue(issue: IMarker): void {
    if (!this.issues) {
      this.issues = [];
    }
    this.issues.push(issue);
  }

  public hasIssue(rule: IRule): boolean {
    return (
      Array.isArray(this.issues) &&
      this.issues.some((i) => i.getRule() === rule)
    );
  }

  public isErroneous(recursive = false): boolean {
    if (this.issues && this.issues.length > 0) {
      return true;
    }
    return (
      recursive &&
      Array.isArray(this.children) &&
      this.children.some((c) => c.isErroneous(true))
    );
  }

  public setNode(field: keyof this, node: Node | null, index = -1): boolean {
    if (node) {
      node.attachTo(this, index);
      (<any>this)[field] = node;
      return true;
    }
    return false;
  }

  public addChild(node: Node | null): node is Node {
    if (node) {
      if (!this.children) {
        this.children = [];
      }
      node.attachTo(this);
      this.updateOffsetAndLength(node);
      return true;
    }
    return false;
  }

  private updateOffsetAndLength(node: Node): void {
    if (node.offset < this.offset || this.offset === -1) {
      this.offset = node.offset;
    }
    const nodeEnd = node.end;
    if (nodeEnd > this.end || this.length === -1) {
      this.length = nodeEnd - this.offset;
    }
  }

  public hasChildren(): boolean {
    return !!this.children && this.children.length > 0;
  }

  public getChildren(): Node[] {
    return this.children ? this.children.slice(0) : [];
  }

  public getChild(index: number): Node | null {
    if (this.children && index < this.children.length) {
      return this.children[index];
    }
    return null;
  }

  public addChildren(nodes: Node[]): void {
    for (const node of nodes) {
      this.addChild(node);
    }
  }

  public findFirstChildBeforeOffset(offset: number): Node | null {
    if (this.children) {
      let current: Node | null = null;
      for (let i = this.children.length - 1; i >= 0; i--) {
        // iterate until we find a child that has a start offset smaller than the input offset
        current = this.children[i];
        if (current.offset <= offset) {
          return current;
        }
      }
    }
    return null;
  }

  public findChildAtOffset(offset: number, goDeep: boolean): Node | null {
    const current: Node | null = this.findFirstChildBeforeOffset(offset);
    if (current && current.end >= offset) {
      if (goDeep) {
        return current.findChildAtOffset(offset, true) || current;
      }
      return current;
    }
    return null;
  }

  public encloses(candidate: Node): boolean {
    return (
      this.offset <= candidate.offset &&
      this.offset + this.length >= candidate.offset + candidate.length
    );
  }

  public getParent(): Node | null {
    let result = this.parent;
    while (result instanceof Nodelist) {
      result = result.parent;
    }
    return result;
  }

  public findParent(type: NodeType): Node | null {
    // eslint-disable-next-line @typescript-eslint/no-this-alias
    let result: Node | null = this;
    while (result && result.type !== type) {
      result = result.parent;
    }
    return result;
  }

  public findAParent(...types: NodeType[]): Node | null {
    // eslint-disable-next-line @typescript-eslint/no-this-alias
    let result: Node | null = this;
    while (result && !types.some((t) => result!.type === t)) {
      result = result.parent;
    }
    return result;
  }

  public setData(key: string, value: any): void {
    if (!this.options) {
      this.options = {};
    }
    this.options[key] = value;
  }

  public getData(key: string): any {
    // eslint-disable-next-line no-prototype-builtins
    if (!this.options || !this.options.hasOwnProperty(key)) {
      return null;
    }
    return this.options[key];
  }

  public toJSON(): any {
    const result: any = {};
    result.type = NodeType[this.type];
    result.text = this.getText();
    result.offset = this.offset;
    result.length = this.length;
    if (this.children) {
      result.children = this.children.map((c) => c.toJSON());
    }
    return result;
  }
}

export interface NodeConstructor<T> {
  new (offset: number, len: number): T;
}

export class Nodelist extends Node {
  private _nodeList!: void;

  constructor(parent: Node, index = -1) {
    super(-1, -1);
    this.attachTo(parent, index);
    this.offset = -1;
    this.length = -1;
  }
}

export class Identifier extends Node {
  public referenceTypes?: ReferenceType[];

  constructor(offset: number, length: number) {
    super(offset, length);
  }

  public get type(): NodeType {
    return NodeType.Identifier;
  }

  public getName(): string {
    return this.getText();
  }
}

export class SourceText extends Node {
  public get type(): NodeType {
    return NodeType.SourceText;
  }
}

export class Assignment extends Node {
  private identifier: Identifier | undefined;
  private value: Node | undefined;

  constructor(offset: number, length: number) {
    super(offset, length);
  }

  public setIdentifier(
    node: Identifier | undefined | null
  ): node is Identifier {
    if (node) {
      node.attachTo(this);
      this.identifier = node;
      return true;
    }
    return false;
  }

  public getIdentifier(): Identifier | undefined {
    return this.identifier;
  }

  public getName(): string {
    return this.identifier ? this.identifier.getName() : "";
  }

  public setValue(node: Node | undefined | null): node is Node {
    if (node) {
      node.attachTo(this);
      this.value = node;
      return true;
    }
    return false;
  }

  public getValue(): Node | undefined {
    return this.value;
  }
}

export class Declarations extends Node {
  private _declarations!: void; // workaround for https://github.com/Microsoft/TypeScript/issues/18276

  constructor(offset: number, length: number) {
    super(offset, length);
  }

  public get type(): NodeType {
    return NodeType.Declarations;
  }
}

/**
 * A node that contains body declarations. For example, for a function, the body declarations are the statements inside the function. For a module, the declarations include the parameter port list, port declarations, and module items.
 */
export class BodyDeclaration extends Node {
  public declarations?: Declarations[];

  constructor(offset: number, length: number) {
    super(offset, length);
  }

  public getDeclarations(): Declarations[] | undefined {
    return this.declarations;
  }

  public pushDeclarations(decls: Declarations | null): decls is Declarations {
    if (decls) {
      if (!this.declarations) {
        this.declarations = [];
      }
      decls.attachTo(this);
      this.declarations.push(decls);
      return true;
    }
    return false;
  }
}

export class ModuleDeclaration extends BodyDeclaration {
  public moduleKeyword?: Node;
  public identifier?: Identifier;

  public get type(): NodeType {
    return NodeType.ModuleDeclaration;
  }

  public setModuleKeyword(moduleKeyword: Node | null): moduleKeyword is Node {
    return this.setNode("moduleKeyword", moduleKeyword, 0);
  }

  public getModuleKeyword(): Node | undefined {
    return this.moduleKeyword;
  }

  public setIdentifier(node: Identifier | null): node is Identifier {
    return this.setNode("identifier", node, 0);
  }

  public getIdentifier(): Identifier | undefined {
    return this.identifier;
  }

  public getName(): string {
    return this.identifier ? this.identifier.getText() : "";
  }
}

export class PackageDeclaration extends BodyDeclaration {
  public identifier?: Identifier;

  public get type(): NodeType {
    return NodeType.PackageDeclaration;
  }

  public setIdentifier(node: Identifier | null): node is Identifier {
    return this.setNode("identifier", node, 0);
  }

  public getIdentifier(): Identifier | undefined {
    return this.identifier;
  }

  public getName(): string {
    return this.identifier ? this.identifier.getText() : "";
  }
}

export class AnsiPortDeclaration extends Node {
  portDirection?: Node;
  netOrVarDataType?: Node;
  identifier?: Identifier;
  value?: Node;

  public get type(): NodeType {
    return NodeType.AnsiPortDeclaration;
  }

  public setPortDirection(node: Node | null): node is Node {
    return this.setNode("portDirection", node, 0);
  }

  public getPortDirection(): Node | undefined {
    return this.portDirection;
  }

  public setNetOrVarDataType(node: Node | null): node is Node {
    return this.setNode("netOrVarDataType", node, 0);
  }

  public getNetOrVarDataType(): Node | undefined {
    return this.netOrVarDataType;
  }

  public setIdentifier(node: Identifier | null): node is Identifier {
    return this.setNode("identifier", node, 0);
  }

  public getIdentifier(): Identifier | undefined {
    return this.identifier;
  }

  public setValue(node: Node | null): node is Node {
    return this.setNode("value", node, 0);
  }

  public getValue(): Node | undefined {
    return this.value;
  }

  public getName(): string {
    return this.identifier ? this.identifier.getText() : "";
  }
}

export class FunctionDeclaration extends BodyDeclaration {
  public identifier?: Identifier;

  public get type(): NodeType {
    return NodeType.FunctionDeclaration;
  }

  public setIdentifier(node: Identifier | null): node is Identifier {
    return this.setNode("identifier", node, 0);
  }

  public getIdentifier(): Identifier | undefined {
    return this.identifier;
  }

  public getName(): string {
    return this.identifier ? this.identifier.getText() : "";
  }
}

export class TaskDeclaration extends BodyDeclaration {
  public identifier?: Identifier;

  public get type(): NodeType {
    return NodeType.TaskDeclaration;
  }

  public setIdentifier(node: Identifier | null): node is Identifier {
    return this.setNode("identifier", node, 0);
  }

  public getIdentifier(): Identifier | undefined {
    return this.identifier;
  }

  public getName(): string {
    return this.identifier ? this.identifier.getText() : "";
  }
}

export class ParameterDeclaration extends Node {
  public get type(): NodeType {
    return NodeType.ParameterDeclaration;
  }
}

export class LocalParameterDeclaration extends Node {
  public get type(): NodeType {
    return NodeType.LocalParameterDeclaration;
  }
}

export class ParamAssignment extends Assignment {
  constructor(offset: number, length: number) {
    super(offset, length);
  }

  public get type(): NodeType {
    return NodeType.ParamAssignment;
  }
}

export class TypeDeclaration extends Node {
  private identifier: Identifier | undefined;
  private dataType: DataType | EnumDataType | StructUnionDataType | undefined;

  constructor(offset: number, length: number) {
    super(offset, length);
  }

  public get type(): NodeType {
    return NodeType.TypeDeclaration;
  }

  public setIdentifier(
    node: Identifier | undefined | null
  ): node is Identifier {
    if (node) {
      node.attachTo(this);
      this.identifier = node;
      return true;
    }
    return false;
  }

  public getIdentifier(): Identifier | undefined {
    return this.identifier;
  }

  public setDataType(
    node: DataType | EnumDataType | StructUnionDataType | undefined | null
  ): node is Node {
    if (node) {
      node.attachTo(this);
      this.dataType = node;
      return true;
    }
    return false;
  }

  public getDataType():
    | DataType
    | EnumDataType
    | StructUnionDataType
    | undefined {
    return this.dataType;
  }

  public getName(): string {
    return this.identifier ? this.identifier.getName() : "";
  }
}

export class VariableDeclaration extends Node {
  public get type(): NodeType {
    return NodeType.VariableDeclaration;
  }
}

export class NetDeclaration extends Node {
  public get type(): NodeType {
    return NodeType.NetDeclaration;
  }
}

export class VariableDeclAssignment extends Assignment {
  constructor(offset: number, length: number) {
    super(offset, length);
  }

  public get type(): NodeType {
    return NodeType.VariableDeclAssignment;
  }
}

export class NetDeclAssignment extends Assignment {
  constructor(offset: number, length: number) {
    super(offset, length);
  }

  public get type(): NodeType {
    return NodeType.NetDeclAssignment;
  }
}

export class ConstantParamExpression extends Node {
  public get type(): NodeType {
    return NodeType.ConstantParamExpression;
  }
}

export class DataType extends Node {
  // Includes string/chandle/virtual_interface/event/
  // data_type_primitives/packageorclass/typereference for now
  public get type(): NodeType {
    return NodeType.DataType;
  }
}

export class EnumDataType extends BodyDeclaration {
  private baseType?: DataType;

  constructor(offset: number, length: number) {
    super(offset, length);
  }

  public get type(): NodeType {
    return NodeType.EnumDataType;
  }

  public setBaseType(node: DataType | undefined | null): node is DataType {
    if (node) {
      node.attachTo(this);
      this.baseType = node;
      return true;
    }
    return false;
  }

  public getBaseType(): DataType | undefined {
    return this.baseType;
  }
}

export class EnumNameDeclaration extends Assignment {
  constructor(offset: number, length: number) {
    super(offset, length);
  }

  public get type(): NodeType {
    return NodeType.EnumNameDeclaration;
  }
}

export class StructUnionDataType extends BodyDeclaration {
  constructor(offset: number, length: number) {
    super(offset, length);
  }

  public get type(): NodeType {
    return NodeType.StructUnionDataType;
  }
}

export class StructUnionMember extends Node {
  private dataType: undefined;

  public get type(): NodeType {
    return NodeType.StructUnionMember;
  }
}

export class Expression extends Node {
  public get type(): NodeType {
    return NodeType.Expression;
  }
}

export interface IRule {
  id: string;
  message: string;
}

export enum Level {
  Ignore = 1,
  Warning = 2,
  Error = 4,
}

export interface IMarker {
  getNode(): Node;
  getMessage(): string;
  getOffset(): number;
  getLength(): number;
  getRule(): IRule;
  getLevel(): Level;
}

export class Marker implements IMarker {
  private node: Node;
  private rule: IRule;
  private level: Level;
  private message: string;
  private offset: number;
  private length: number;

  constructor(
    node: Node,
    rule: IRule,
    level: Level,
    message?: string,
    offset: number = node.offset,
    length: number = node.length
  ) {
    this.node = node;
    this.rule = rule;
    this.level = level;
    this.message = message || rule.message;
    this.offset = offset;
    this.length = length;
  }

  public getRule(): IRule {
    return this.rule;
  }

  public getLevel(): Level {
    return this.level;
  }

  public getOffset(): number {
    return this.offset;
  }

  public getLength(): number {
    return this.length;
  }

  public getNode(): Node {
    return this.node;
  }

  public getMessage(): string {
    return this.message;
  }
}

export interface IVisitor {
  visitNode: (node: Node) => boolean;
}

export interface IVisitorFunction {
  (node: Node): boolean;
}
