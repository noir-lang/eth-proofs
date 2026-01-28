// Nargo 1.0+ foreign call protocol types

export interface SingleForeignCallParam {
  Single: string;
}

export interface ArrayForeignCallParam {
  Array: string[];
}

export type ForeignCallParam = SingleForeignCallParam | ArrayForeignCallParam;
export type ForeignCallParams = ForeignCallParam[];

export interface ResolveForeignCallResult {
  values: (string | string[])[];
}
