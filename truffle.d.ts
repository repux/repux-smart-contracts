declare type _contractTest = (accounts: string[]) => void;
declare function contract(name: string, test: _contractTest): void;
declare interface TransactionMeta {
  from: string,
}

declare interface Contract<T> {
  "new"(...arguments : any[]): Promise<T>,
  deployed(): Promise<T>,
  at(address: string): T,
  constructor() : Contract<T>
  address: string
}

declare interface DataProductInstance {
    purchase() : Promise<void>
    purchaseFor(recipient: string) : Promise<void>
    description() : Promise<string>
    setDescription(newDescription : string) : Promise<void>

    constructor() : DataProductInstance
}

interface Artifacts {
  require(name: "./DataProduct.sol"): Contract<DataProductInstance>,
  require(name : string): Contract<any>,
}

declare var artifacts: Artifacts;