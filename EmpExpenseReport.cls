/**
 * @description Diese Klasse stellt einen Controller für die Anzeige von Mitarbeiter-Spesenberichten dar.
 * Und verfügt über drei Methoden, die für die Daten des Abrechnungsobjektes benötigt werden
 * @author aquilliance GmbH - Andreas Ivens
 * Modified By			Modified on		Ticket No.		Comments
 * Andreas Ivens		2024-05-03		        		initial version
 */
public with sharing class EmpExpenseReport {
    /**
     * @description Hier werden die Variablen deklariert, 
     * die auf der Visualforce-Seite verwendet werden.
     */
    public String reportName {get; set;}
    public String employee {get;set;}
    public String startDate {get;set;}
    public String endDate {get;set;}
    public String totalReimbursement {get;set;}
    public String checkQuestion1 {get; set;}
    public String checkQuestion2 {get; set;}
    public String checkQuestion3 {get; set;}
    public String checkQuestion4 {get; set;}
    public String curCity {get;set;}
    public String now {get;set;}
    public String company {get; set;}
    public String actualYear {get; set;}
    public List<EmpExpenseReportHelper> relatedStrings {get; private set;}
    public Boolean isEvenRow {get; set;}
    public List<Expense__c> relatedExpenses {get;set;}
    public String reportId {get;set;}
    public Employee_Expense_Accounting__c report {get;set;}
    public String warning {get; set;}

    /**
     * @description Hier werden beim Erstellen der Klasse verschiedene Variablen initialisiert 
     * und Daten abgerufen, die für die Anzeige auf der Seite benötigt werden.
     */
    public EmpExpenseReport(){
        reportId = ApexPages.currentPage().getParameters().get('reportId');
        company = ' aquilliance GmbH & aquilliance digital marketing GmbH ';
        checkQuestion1 = 'Sind alle Spesendaten korrekt erfasst?';
        checkQuestion2 = 'Sind alle Spesendaten korrekt?';
        checkQuestion3 = 'Sind alle Belege Angehängt, in der richtigen Reihenfolge?';
        checkQuestion4 = 'Sind alle Belege mit der entsprechenden Expensenummer beschriftet?';
        warning = 'Achtung! Diese Checkliste bitte sorgfältig ausfüllen. Spesen werden nur erstattet, wenn alle Spesen ordentlich geprüft sind.';
        now = genDate(Date.today());
        actualYear = String.valueOf(Date.today().year());
        // // Abrufen des Berichts für die angegebene reportId
        List<Employee_Expense_Accounting__c> reports = [SELECT Id, Name, Accounting_Start__C, Accounting_End__c, Employee__c, Approve__c 
        FROM Employee_Expense_Accounting__c WHERE Id = :reportId]; 
        if(reports.size() != 1){
            return;
        }
        this.report = reports[0];
        List<Contact> curContact = [Select Id, MailingCity From Contact WHERE Id =: reports[0].Employee__c];
        curCity = curContact[0].MailingCity;
        // Abrufen der mit dem Bericht verknüpften Ausgaben
        List<Expense_for_accounting__c> curJuncs = [Select Id, Name, Selected_Expense__c, Expense_for_Approval__c FROM 
        Expense_for_Accounting__c WHERE Expense_for_Approval__c =: reportId];
        Set<Id> expensesIds = new Set<Id>();
        for(Expense_for_Accounting__c junc: curJuncs){
            Id expenseId = junc.Selected_Expense__c;
            expensesIds.add(expenseId);
        }
        relatedExpenses = [Select Id, Name, Project__c, Type__c, Reason__c, Charge__c, Reimbursement_Employee__c , 
        Date__c, Employee_v2__c, Employee_v2__r.Name ,Project__r.Name, Stage__c 
        FROM Expense__c WHERE Id IN : expensesIds];
        isEvenRow = false;
        // Verarbeitung der mit dem Bericht verknüpften Ausgaben
        relatedStrings = EmpExpenseReportHelper.getData(relatedExpenses);
        // Berechnung der Gesamtrückerstattung
        totalReimbursement = genReimbursement(relatedExpenses);
        // Abrufen und Formatieren von Daten für die Anzeige
        List<Contact> emp = [Select Id, Name FROM Contact WHERE Id =: reports[0].Employee__c];
        employee = String.valueOf(emp[0].Name);
        for(Employee_Expense_Accounting__c rep: reports){
            reportName = String.valueOf(rep.Name);
            startDate = genDate(rep.Accounting_Start__c);
            endDate = genDate(rep.Accounting_End__c);
        }
    }  

    /**
     * @description DIese Methode generiert aus einem übergebenen Datum,
     * das z.B. aus einem Report stammt in einen String um,
     * der nur das Datum ohne Zeit beinhaltet
     * @param before 
     * @return  `String`
     */
    static String genDate(Date before){
        String fullDate = String.valueOf(before);
        String year = fullDate.substringBefore('-');
        String month = fullDate.substring(5, 7); 
        String day = fullDate.substring(8, 10);
        String returnDate = day+'.'+month+'.'+year;

        return returnDate;
    }

    /**
     * @description Diese Methode bekommt eine List mit Expense übergeben,
     * sie rechnet alle Reimbursements zusammen und gibt den errechneten Wert,
     * als String zurück
     * @param before 
     * @return  `String`
     */
    static String genReimbursement(List<Expense__c> before){
        Double curReimbursement = 0;
        String toReimbursement;
        for(Expense__c ex: before){
            curReimbursement += ex.Reimbursement_Employee__c;
            String fullDoubleReimbursement = String.valueOf(curReimbursement);
            String fullIntReimbursement = fullDoubleReimbursement.substringBefore('.');
            String fullDecimalReimbursement = fullDoubleReimbursement.substringAfter('.');
            toReimbursement = fullIntReimbursement+','+fullDecimalReimbursement; 
            String [] partsReimbursement = toReimbursement.split(',');
            if(partsReimbursement.size() == 1){
                toReimbursement += ',0';
            }else if(partsReimbursement[1].length() == 1){
                toReimbursement = partsReimbursement[0] + ',' + partsReimbursement[1] + '0';
            }
        }
        return toReimbursement;
    }
}
 

        
       
    