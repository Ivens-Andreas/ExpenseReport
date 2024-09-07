/**
 * @description Helferklasse zum Aufbereiten der Expense-Daten für die PDF.
 *              Diese Klasse wandelt Expense__c-Objekte in Helferobjekte um, die aus Strings bestehen.
 * @author aquilliance GmbH - Andreas Ivens
 * Modified By         Modified on        Ticket No.        Comments
 * Andreas Ivens       2024-05-08                           initial version
 */
public with sharing class EmpExpenseReportHelper {
    
    // Attribute der Klasse
    public Expense__c newExpense;
    public String expenseId {get; set;}
    public String expenseName {get; set;}
    public String expenseDate {get; set;}
    public String project {get; set;}
    public String type {get; set;}
    public String reason {get; set;}
    public String charge {get; set;}
    public String reimbursement {get; set;}
    public String employee {get; set;}
    
      /**
     * @description Methode zum Aufbereiten der Expense-Daten für die Erstellung der Abrechnungs-PDF.
     * @param expenses Eine Liste von Expense__c-Objekten
     * @return List<EmpExpenseReportHelper> Eine Liste von Helferobjekten, die für die PDF-Erstellung benötigt werden
     */
    public static List<EmpExpenseReportHelper> getData(List<Expense__c> expenses){
        List<EmpExpenseReportHelper> relatedStrings = new List<EmpExpenseReportHelper>();
        for(Expense__c exp: expenses){
                // Neue Instanz des Helferobjekts erstellen
                EmpExpenseReportHelper first = new EmpExpenseReportHelper();
                // Felder des Helferobjekts mit den Werten aus dem Expense__c-Objekt befüllen
                first.newExpense = exp;
                first.expenseId = String.valueOf(exp.Id);
                first.expenseName = String.valueOf(exp.Name);
                // Datum formatieren
                String fullDate = String.valueOf(exp.Date__c);
                String year = fullDate.substringBefore('-');
                String month = fullDate.substring(5, 7);
                String day = fullDate.substring(8, 10);
                first.expenseDate = day+'.'+ month+'.' + year;
                first.project = String.valueOf(exp.Project__r.Name);
                first.type = exp.Type__c;
                first.reason = exp.Reason__c;
                first.employee = String.valueOf(exp.Employee_v2__r.Name);
                // Reimbursement und Gebühren formatieren
                String reimburse = String.valueOf(exp.Reimbursement_Employee__c);
                String charges = String.valueOf(exp.Charge__c);
                first.reimbursement = reimburse.substringBefore('.') + ',' + reimburse.substringAfter('.');
                first.charge = charges.substringBefore('.') + ',' + charges.substringAfter('.');
                // Hinzufügen des Helferobjekts zur Liste
                relatedStrings.add(first);
        }
        return relatedStrings;
    }
}