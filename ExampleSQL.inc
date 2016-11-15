ROUTINE ExampleSQL [Type=INC]
/// Throws an sqlcode/message pair as an exception
#define ThrowSQLCODE(%sqlcode,%message) $$$ThrowStatus($$$ERROR($$$SQLError,%sqlcode,%message))

/// Throws an exception if a result object (%SQL.StatementResult or result set) has an error code
#define THROWONRESULTERROR(%result) if (%result.%SQLCODE)<0 { $$$ThrowSQLCODE(%result.%SQLCODE,%result.%Message) }
#define QUITONRESULTERROR(%result) quit:(%result.%SQLCODE)<0 $$$ERROR($$$SQLError,%result.%SQLCODE,%result.%Message)
