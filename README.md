# experiment-tabulator
Small script that takes a concise syntax explaining your experimental design and turns it into a "[tidy](https://r4ds.had.co.nz/tidy-data.html)" experimental metadata table.

For example, the prompt

`(Control)(0) + (TreatmentA; TreatmentB)(1mg/kg, 3mg/kg; 10mg/kg, 100mg/kg)`

becomes

|Var2       |Var3     |
|:----------|:--------|
|Control    |0        |
|TreatmentA |1mg/kg   |
|TreatmentA |3mg/kg   |
|TreatmentB |10mg/kg  |
|TreatmentB |100mg/kg |

We can add experimental replicates simply by adding a number anywhere outside the brackets:

`3(Control)(0) + 3(TreatmentA; TreatmentB)(1mg/kg, 3mg/kg; 10mg/kg, 100mg/kg)`

becomes


|Var2       |Var3     |
|:----------|:--------|
|Control    |0        |
|Control    |0        |
|Control    |0        |
|TreatmentA |1mg/kg   |
|TreatmentA |1mg/kg   |
|TreatmentA |1mg/kg   |
|TreatmentA |3mg/kg   |
|TreatmentA |3mg/kg   |
|TreatmentA |3mg/kg   |
|TreatmentB |10mg/kg  |
|TreatmentB |10mg/kg  |
|TreatmentB |10mg/kg  |
|TreatmentB |100mg/kg |
|TreatmentB |100mg/kg |
|TreatmentB |100mg/kg |

What if we have another variable?

`3(Untreated) + 3(TreatmentA; TreatmentB)(1mg/kg, 3mg/kg; 10mg/kg, 100mg/kg)(oral, injection)`

becomes

|Var2       |Var3     |Var4      |
|:----------|:--------|:---------|
|Untreated  |NA       |NA        |
|Untreated  |NA       |NA        |
|Untreated  |NA       |NA        |
|TreatmentA |1mg/kg   |oral      |
|TreatmentA |1mg/kg   |oral      |
|TreatmentA |1mg/kg   |oral      |
|TreatmentA |1mg/kg   |injection |
|TreatmentA |1mg/kg   |injection |
|TreatmentA |1mg/kg   |injection |
|TreatmentA |3mg/kg   |oral      |
|TreatmentA |3mg/kg   |oral      |
|TreatmentA |3mg/kg   |oral      |
|TreatmentA |3mg/kg   |injection |
|TreatmentA |3mg/kg   |injection |
|TreatmentA |3mg/kg   |injection |
|TreatmentB |10mg/kg  |oral      |
|TreatmentB |10mg/kg  |oral      |
|TreatmentB |10mg/kg  |oral      |
|TreatmentB |10mg/kg  |injection |
|TreatmentB |10mg/kg  |injection |
|TreatmentB |10mg/kg  |injection |
|TreatmentB |100mg/kg |oral      |
|TreatmentB |100mg/kg |oral      |
|TreatmentB |100mg/kg |oral      |
|TreatmentB |100mg/kg |injection |
|TreatmentB |100mg/kg |injection |
|TreatmentB |100mg/kg |injection |

At the moment, the first column starts from "Var2" as an artifact of using expand.grid under the hood.
