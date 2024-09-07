
/**
 * @description 
 * @author aquilliance GmbH - Andreas Ivens
 * Modified By			Modified on		Ticket No.		Comments
 * Andreas Ivens		2024-05-12	        		    initial version
 */
@isTest
public with sharing class EmployeeExpenseReportTest {

    /**
     * @description Methode zum Generieren von Testdaten für die Testmethoden.
     * @return Account Objekt des Ausstellers
     */
    private static Account genIssuerAccount(){
        Account issuerAcc = new Account(
            Name = 'TestIssuer',
            aqu__Is_Invoice_Issuer__c = true,
            aqu__Org_Wide_E_Mail_Address__c = 'einfachWir@etwasAnderes.da',
            aqu__Commercial_register_entry__c = 'HHBA-278591',
            aqu__VAT_ID__c = 'KL124M522586',
            Website = 'www.google.de',
            aqu__Bank_Name__c = 'Test Bank',
            aqu__BIC__c = 'XXWW2574',
            aqu__IBAN__c = 'DE789452895544',
            aqu__Invoice_Logo__c = '/test/logo/logo.png',
            aqu__Invoice_Logo_Position__c = 'Center',
            aqu__Invoice_Number_Prefix__c = 'IP',
            BillingStreet = 'Hammerbrook Straße 90',
            BillingPostalCode = '20097',
            BillingCity = 'Hamburg'
        );
        return issuerAcc;
    }

    /**
     * @description Methode zum Generieren von Testdaten für die Testmethoden.
     * @param issuerId Die Id des Aussteller-Accounts
     * @return Account Objekt des übergeordneten Accounts
     */
    private static Account genParentAccount(Id issuerId){
        Account parentAcc = new Account(
            Type = 'Customer',
            Name = 'DateTestAcc',
            Industry = 'Banking / Finance',
            AccountSource = 'Chatbot',
            aqu__Invoice_Issuer__c = issuerId,
            BillingStreet = 'Hammerbrook Straße 90',
            BillingPostalCode = '20097',
            BillingCity = 'Hamburg',
            aqu__Is_Invoice_Customer__c = true
        );
        
        return parentAcc;
    }

   /**
     * @description Methode zum Generieren von Testdaten für die Testmethoden.
     * @param parentId Die Id des übergeordneten Accounts
     * @param issuerId Die Id des Aussteller-Accounts
     * @return Project__c Objekt des Projekts
     */
    private static Project__c genProject(Id parentId, Id issuerId){
        Project__c newProject = new Project__c(
            Name = 'TestClass', 
            Project_Manager__c = UserInfo.getUserId(), 
            aqu_Lead_Developer__c = UserInfo.getUserId(),  
            Revenue_Type__c = 'Salesforce_Project',
            Deadline__c = Date.newInstance(2024, 12, 31),
            Account__c = parentId, 
            Invoice_Issuer__c = issuerId
            );
        
        return newProject;
    }
    
    /**
     * @description Methode zum Generieren von Testdaten für die Testmethoden.
     * @return Contact Objekt 
     */
    private static Contact genContact(){
        Contact con = new Contact(
            Related_User__c = UserInfo.getUserId(),
            RecordTypeId = UserInfo.getUserId(),
            Salutation = 'Herr',
            FirstName = 'Andreas',
            LastName = 'Ivens',
            MailingCity = 'Hamburg'
        );
        return con;
    }
    
    /**
     * @description Methode zum Generieren von Testdaten für die Testmethoden.
     * @param projectId Die Id des Projektes zu dem die Expense gehört
     * @param con Ist der Kontakt der den Mitarbeiter darstellt
     * @return List<Expenses__c> Objekte
     */
    private static List<Expense__c> genExpense(Id projectId, Contact con){
        List<Expense__c> expenses = new List<Expense__c>();
        for(Integer i=0; i<5; i++){
            Expense__c exp = new Expense__c(
                Employee__c = UserInfo.getUserId(),
                Expense_of__c = 'Employee',
                Project__c = projectId,
                Date__c = Date.today(),
                Type__c = 'Zug',
                Stage__c = null,
                Charge__c = 57
                

            );
            expenses.add(exp);
        }
        
        return expenses;
    }

    /**
     * @description Methode zum Generieren von Testdaten für die Testmethoden.
     * @param conId Die Id des Kontaktes zu einem Report
     * @return Employee_Expense_Accounting__c Objekt, der Datensatz für einen Report
     */
    private static Employee_Expense_Accounting__c genReport(Id conId){
        Employee_Expense_Accounting__c report = new Employee_Expense_Accounting__c(
            Accounting_Start__c = Date.today(),
            Accounting_End__c = Date.today(),
            Employee__c = conId,
            Expense_charge_request__c = null,
            Expense_reimbursement_request__c = null,
            Approve__c = null


        );
        return report;

    }
    
    @TestSetup
    static void makeData(){
        Account issuerAcc = genIssuerAccount();
        insert issuerAcc;
        Account parentAcc = genParentAccount(issuerAcc.Id);
        insert parentAcc;
        Project__c newProject = genProject(parentAcc.Id, issuerAcc.Id);
        insert newProject;
        Contact con = genContact();
        List<Expense__c> exp = genExpense(newProject.Id, con);
        insert exp;
        Employee_Expense_Accounting__c report = genReport(con.Id);
        insert report;
    }

    /**
     * @description Methode zum Testen der Helferklasse.
     * @return List<EmpExpenseReportHelper>
     */
    @isTest
    static void testGetDataMethode(){
        // Test für die getData-Methode in EmpExpenseReportHelper-Klasse
        
        // Testdaten vorbereiten
        List<Expense__c> expenses = [SELECT Id, Name, Date__c, Project__r.Name, Type__c, Reason__c, 
        Reimbursement_Employee__c, Charge__c, Employee_v2__r.Name FROM Expense__c];
        
        // Testdaten für die Helper-Methode vorbereiten
        List<EmpExpenseReportHelper> expectedResults = new List<EmpExpenseReportHelper>();
        for(Expense__c exp : expenses) {
            EmpExpenseReportHelper helper = new EmpExpenseReportHelper();
            helper.newExpense = exp;
            helper.expenseId = String.valueOf(exp.Id);
            helper.expenseName = String.valueOf(exp.Name);
            String fullDate = String.valueOf(exp.Date__c);
            String year = fullDate.substringBefore('-');
            String month = fullDate.substring(5, 7);
            String day = fullDate.substring(8, 10);
            helper.expenseDate = day+'.'+ month+'.' + year;
            helper.project = String.valueOf(exp.Project__r.Name);
            helper.type = exp.Type__c;
            helper.reason = exp.Reason__c;
            helper.employee = String.valueOf(exp.Employee_v2__r.Name);
            String reimburse = String.valueOf(exp.Reimbursement_Employee__c);
            String charges = String.valueOf(exp.Charge__c);
            helper.reimbursement = reimburse.substringBefore('.') + ',' + reimburse.substringAfter('.');
            helper.charge = charges.substringBefore('.') + ',' + charges.substringAfter('.');
            
            expectedResults.add(helper);
        }
        
        // Helper-Methode aufrufen
        List<EmpExpenseReportHelper> actualResults = EmpExpenseReportHelper.getData(expenses);
        
        // Ergebnisse vergleichen
        System.assertEquals(expectedResults.size(), actualResults.size(), 'Anzahl der erwarteten und tatsächlichen Ergebnisse stimmen nicht überein');
        for(Integer i=0; i<expectedResults.size(); i++) {
            EmpExpenseReportHelper expected = expectedResults[i];
            EmpExpenseReportHelper actual = actualResults[i];
            
            System.assertEquals(expected.newExpense, actual.newExpense, 'Neue Ausgaben stimmen nicht überein');
            System.assertEquals(expected.expenseId, actual.expenseId, 'Ausgaben-ID stimmen nicht überein');
            System.assertEquals(expected.expenseName, actual.expenseName, 'Ausgabenname stimmen nicht überein');
            System.assertEquals(expected.expenseDate, actual.expenseDate, 'Ausgabendatum stimmen nicht überein');
            System.assertEquals(expected.project, actual.project, 'Projekt stimmen nicht überein');
            System.assertEquals(expected.type, actual.type, 'Typ stimmen nicht überein');
            System.assertEquals(expected.reason, actual.reason, 'Grund stimmen nicht überein');
            System.assertEquals(expected.charge, actual.charge, 'Gebühren stimmen nicht überein');
            System.assertEquals(expected.reimbursement, actual.reimbursement, 'Erstattung stimmen nicht überein');
            System.assertEquals(expected.employee, actual.employee, 'Mitarbeiter stimmen nicht überein');
        }
    }

    /**
     * @description Methode zum Testen der Attribute in der Helferklasse.
     */
    @isTest
    static void testEmpExpenseReportHelperAttributes() {
        // Erstellen einer Instanz von EmpExpenseReportHelper
        EmpExpenseReportHelper helper = new EmpExpenseReportHelper();
        
        // Überprüfen der einzelnen Attribute
        System.assertEquals(null, helper.newExpense, 'newExpense sollte null sein.');
        System.assertEquals(null, helper.expenseId, 'expenseId sollte null sein.');
        System.assertEquals(null, helper.expenseName, 'expenseName sollte null sein.');
        System.assertEquals(null, helper.expenseDate, 'expenseDate sollte null sein.');
        System.assertEquals(null, helper.project, 'project sollte null sein.');
        System.assertEquals(null, helper.type, 'type sollte null sein.');
        System.assertEquals(null, helper.reason, 'reason sollte null sein.');
        System.assertEquals(null, helper.charge, 'charge sollte null sein.');
        System.assertEquals(null, helper.reimbursement, 'reimbursement sollte null sein.');
        System.assertEquals(null, helper.employee, 'employee sollte null sein.');
        
    }
    /**
     * @description Methode zum Testen der Attribute im Konstruktor der EmpExpenseReportklasse.
     */
    @isTest
    static void testConstructor() {
        // Erstellen einer Instanz der EmpExpenseReport-Klasse
        Account accI = genIssuerAccount();
        Account accP = genParentAccount(accI.Id);
        Contact con = genContact();
        Project__c pro = genProject(accI.Id, accP.Id);
        List<Expense__c> expenses = genExpense(pro.Id, con);
       
        Employee_Expense_Accounting__c repo = new Employee_Expense_Accounting__c();
        repo.Accounting_Start__c = Date.today()-31;
        repo.Accounting_End__c = Date.today()-2;
        repo.Employee__c = con.Id;
        repo.Approve__c = null;
        insert repo;
        List<Employee_Expense_Accounting__c> rep = [Select Id, Name, Accounting_Start__c, 
        Accounting_End__c, Employee__c FROM Employee_Expense_Accounting__c];
    
        System.debug('Rep Id: '+rep[0].Id);
        Test.startTest();
        EmpExpenseReport empExpenseReport = new EmpExpenseReport();

    
        Test.stopTest();
        // Überprüfen, ob die Attribute des Konstruktors initialisiert wurden
        rep = [Select Id, Name, Accounting_Start__c, Accounting_End__c, Employee__c FROM Employee_Expense_Accounting__c];
        System.assertNotEquals(String.valueOf(rep[0].Id), repo.Id, 'reportId should not be null');

    }
    /**
     * @description Method die prüft, ob sich die Stage__c der Expenses die neu eingefügt wurden auf Requested ändern,
     * wenn eine neu generiert wird.
     */
    @isTest
    static void stageAfterInsertReport(){
        Account accI = genIssuerAccount();
        Account accP = genParentAccount(accI.Id);
        Contact con = genContact();
        Project__c pro = genProject(accI.Id, accP.Id);
        List<Expense__c> expenses = genExpense(pro.Id, con);
       
        Employee_Expense_Accounting__c repo = new Employee_Expense_Accounting__c();
        repo.Accounting_Start__c = Date.today()-31;
        repo.Accounting_End__c = Date.today()-2;
        repo.Employee__c = con.Id;
        repo.Approve__c = null;
        insert repo;

        expenses = [Select Id, Name, Project__c, Stage__c FROM Expense__c];
        System.assertEquals('Requested', expenses[0].Stage__c, 'Result Expense Stage set to Requested');
    }
    
    /**
     * @description Method die prüft, ob sich die Stage__c der Expenses von Requested auf Approved ändert, 
     * wenn Approve__c in der Abrechnung auf Approved gesetzt wird.
     */
    @isTest
    static void stageChangeToApproved(){
        Account accI = genIssuerAccount();
        Account accP = genParentAccount(accI.Id);
        Contact con = genContact();
        Project__c pro = genProject(accI.Id, accP.Id);
        List<Project__c> pros = [Select Id, Name FROM Project__c];
        List<Expense__c> expenses = genExpense(pro.Id, con);
        Expense__c exp = expenses[0];
        exp.Stage__c = 'Requested';
        exp.Project__c = pros[0].Id;
        insert exp;
       
        Employee_Expense_Accounting__c rep = genReport(con.Id);
        rep.Accounting_Start__c = Date.today()-31;
        rep.Accounting_End__c = Date.today()-2;
        rep.Employee__c = con.Id;
        rep.Approve__c = null;
        insert rep;
        
        List<Employee_Expense_Accounting__c> foundRep = [Select Name, Approve__c From Employee_Expense_Accounting__c];
        Employee_Expense_Accounting__c curRep = foundRep[0];
        curRep.Approve__c = 'Approved';

        update curRep;
    
        expenses = [Select Id, Name, Project__c, Stage__c FROM Expense__c];
        System.assertEquals('Approved', expenses[0].Stage__c, 'Result Expense Stage set to Approved');
    }

    /**
     * @description Method die prüft, ob sich die Stage__c der Expenses von Requested auf Declined ändert, 
     * wenn Approve__c in der Abrechnung auf Declined gesetzt wird.
     */
    @isTest
    static void stageChangeToDeclined(){
        Account accI = genIssuerAccount();
        Account accP = genParentAccount(accI.Id);
        Contact con = genContact();
        Project__c pro = genProject(accI.Id, accP.Id);
        List<Project__c> pros = [Select Id, Name FROM Project__c];
        List<Expense__c> expenses = genExpense(pro.Id, con);
        Expense__c exp = expenses[0];
        exp.Stage__c = 'Requested';
        exp.Project__c = pros[0].Id;
        insert exp;
       
        Employee_Expense_Accounting__c rep = genReport(con.Id);
        rep.Accounting_Start__c = Date.today()-31;
        rep.Accounting_End__c = Date.today()-2;
        rep.Employee__c = con.Id;
        rep.Approve__c = null;
        insert rep;
        
        List<Employee_Expense_Accounting__c> foundRep = [Select Name, Approve__c From Employee_Expense_Accounting__c];
        Employee_Expense_Accounting__c curRep = foundRep[0];
        curRep.Approve__c = 'Declined';

        update curRep;
    
        expenses = [Select Id, Name, Project__c, Stage__c FROM Expense__c];
        System.assertEquals('Declined', expenses[0].Stage__c, 'Result Expense Stage set to Declined');
    }

    /**
     * @description Method die prüft, ob sich die Stage__c der Expenses von Approved auf Transmittedt to tax-advisor ändert,
     * wenn Approve__c in der Abrechnung auf Transmitted to tax-advisor gesetzt wird.
     */
    @isTest
    static void stageChangeToTaxAdvisor(){
        Account accI = genIssuerAccount();
        Account accP = genParentAccount(accI.Id);
        Contact con = genContact();
        Project__c pro = genProject(accI.Id, accP.Id);
        List<Project__c> pros = [Select Id, Name FROM Project__c];
        List<Expense__c> expenses = genExpense(pro.Id, con);
        Expense__c exp = expenses[0];
        exp.Id = expenses[0].Id;
        exp.Stage__c = 'Requested';
        exp.Project__c = pros[0].Id;
        insert exp;

        List<Expense__c> foundExpenses = [Select Id, Name, Project__c, Stage__c FROM Expense__c];
        Expense__c newExp = foundExpenses[0];
        newExp.Stage__c = 'Approved';
        update newExp;
       
        Employee_Expense_Accounting__c rep = genReport(con.Id);
        rep.Accounting_Start__c = Date.today()-31;
        rep.Accounting_End__c = Date.today()-2;
        rep.Employee__c = con.Id;
        rep.Approve__c = 'Approved';
        insert rep;
        
        List<Employee_Expense_Accounting__c> foundRep = [Select Name, Approve__c From Employee_Expense_Accounting__c];
        Employee_Expense_Accounting__c curRep = foundRep[0];
        curRep.Approve__c = 'Transmitted to tax-advisor';

        update curRep;
    
        expenses = [Select Id, Name, Project__c, Stage__c FROM Expense__c];
        System.assertEquals('Transmitted to tax-advisor', expenses[0].Stage__c, 'Result Expense Stage set to Transmitted to tax-advisor');
    }

    /**
     * @description Methode die prüft, ob sich die Stage__c der Expenses von Declined in Requested in Approved ändert, 
     * wenn Approve__c in der Abrechnung auf Approved gesetzt wird.
     */
    @isTest
    static void stageChangeFromDeclinedToApporved(){
        Account accI = genIssuerAccount();
        Account accP = genParentAccount(accI.Id);
        Contact con = genContact();
        Project__c pro = genProject(accI.Id, accP.Id);
        List<Project__c> pros = [Select Id, Name FROM Project__c];
        List<Expense__c> expenses = genExpense(pro.Id, con);
        Expense__c exp = expenses[0];
        exp.Id = expenses[0].Id;
        exp.Stage__c = 'Requested';
        exp.Project__c = pros[0].Id;
        insert exp;

        List<Expense__c> foundExpenses = [Select Id, Name, Project__c, Stage__c FROM Expense__c];
        Expense__c newExp = foundExpenses[0];
        newExp.Stage__c = 'Declined';
        update newExp;
       
        Employee_Expense_Accounting__c rep = genReport(con.Id);
        rep.Accounting_Start__c = Date.today()-31;
        rep.Accounting_End__c = Date.today()-2;
        rep.Employee__c = con.Id;
        rep.Approve__c = 'Declined';
        insert rep;
        
        List<Employee_Expense_Accounting__c> foundRep = [Select Name, Approve__c From Employee_Expense_Accounting__c];
        Employee_Expense_Accounting__c curRep = foundRep[0];
        curRep.Approve__c = 'Approved';

        update curRep;
    
        expenses = [Select Id, Name, Project__c, Stage__c FROM Expense__c];
        System.assertEquals('Approved', expenses[0].Stage__c, 'Result Expense Stage set to Approved');
    }
}