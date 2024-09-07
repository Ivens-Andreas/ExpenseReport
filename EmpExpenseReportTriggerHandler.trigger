/**
 * @description Trigger-Handler, der Aktionen basierend auf den Ereignissen vor oder nach dem Einfügen und Aktualisieren von Employee_Expense_Accounting__c ausführt.
 * Wenn neue Datensätze von Employee_Expense_Accounting__c eingefügt werden, werden die Werte für den Bericht gesetzt und Verknüpfungen erstellt.
 * Wenn Datensätze von Employee_Expense_Accounting__c aktualisiert werden, wird der Status der zugehörigen Ausgaben geändert.
 * Dieser Trigger-Handler ist auf die Ereignisse vor und nach dem Einfügen und Aktualisieren von Datensätzen von Employee_Expense_Accounting__c abonniert.
 * @author aquilliance GmbH - Andreas Ivens
 * Modified By         Modified on        Ticket No.        Comments
 * Andreas Ivens       2024-05-03                           initial version
 */
trigger EmpExpenseReportTriggerHandler on Employee_Expense_Accounting__c (after insert , after update) {
    // Wenn der Trigger nach dem Einfügen ausgelöst wird
    if(Trigger.isAfter && Trigger.isInsert){
        // Setzen der Werte für den Bericht und Erstellen von Verknüpfungen für die neuen Datensätze von Employee_Expense_Accounting__c
        ReportHandlerMethods.fillJunc(Trigger.new);
        ReportHandlerMethods.setValuesForReport(Trigger.new);
        ExpenseReportEmail.genEmailMassageInsert(Trigger.new);
    }
    // Wenn der Trigger nach dem Update ausgelöst wird
    else if(Trigger.isAfter && Trigger.isUpdate){
        // Ändern des Status der zugehörigen Ausgaben für die aktualisierten Datensätze von Employee_Expense_Accounting__c
        ReportHandlerMethods.changeExpenseStatus(Trigger.new);
        ExpenseReportEmail.genEmailMassages(Trigger.new);
    }
}