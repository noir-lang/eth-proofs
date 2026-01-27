// Taken from here: https://noir-lang.org/docs/how_to/how-to-oracles

export interface SingleForeignCallParam {
  Single: string;
}

export interface ArrayForeignCallParam {
  Array: string[];
}

export type ForeignCallParam = SingleForeignCallParam | ArrayForeignCallParam;
export type ForeignCallParams = ForeignCallParam[];

export interface ForeignCallResult {
  values: ForeignCallParams;
}

// New Nargo 1.0+ protocol response format
export interface ResolveForeignCallResult {
  values: (string | string[])[];
}
