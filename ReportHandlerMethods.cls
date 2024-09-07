public with sharing class ReportHandlerMethods {


    /**
     * @description Hier werden die Ausgaben einem Bericht zugeordnet und der Status der Ausgaben wird auf Requested gesetzt.
     * @param report 
     */
    public static void fillJunc(List<Employee_Expense_Accounting__c> report){
        List<Expense_for_Accounting__c> curJuncs = new List<Expense_for_Accounting__c>(); // aus allen loops raus
        List<Expense__c> curExpenses = new List<Expense__c>();
        for(Employee_Expense_Accounting__c rep: report){
            if(rep != null){
                List<Expense__c> relatedExpenses = [Select Id, Employee_v2__c, Stage__c FROM Expense__c WHERE Employee_V2__c =: rep.Employee__c AND Date__c >=: rep.Accounting_Start__C AND Date__c <=: rep.Accounting_End__c];
                for(Expense__c exp: relatedExpenses){
                    if(exp.Stage__c == 'Declined' || exp.Stage__c == null){
                        exp.Stage__c = 'Requested';  // tausch gegen requested
                        Expense_for_Accounting__c junc = new Expense_for_Accounting__c();
                        junc.Selected_Expense__c = exp.Id;
                        junc.Expense_for_Approval__c = rep.Id; 
                        curJuncs.add(junc);
                        curExpenses.add(exp);
                    }
                }
            }
        }
        update curExpenses;
        insert curJuncs;
        update curJuncs; // außerhalb der loop  Warum so umgesezt
    }

    /**
    * @description Hier werden die Werte für die Ausgaben 
    * und die Rückerstattungen für einen Bericht festgelegt.
    * @param newReport 
    */
    public static void setValuesForReport(List<Employee_Expense_Accounting__c> newReport) {
        Set<Id> reportIds = new Set<Id>();
        Set<Id> expenseIds = new Set<Id>();
    
        // Collect report IDs
        for (Employee_Expense_Accounting__c report : newReport) {
            reportIds.add(report.Id);
        }
    
        // Query junction objects
        List<Expense_for_Accounting__c> junctions = [
            Select Id, Selected_Expense__c, Expense_for_Approval__c 
            FROM Expense_for_Accounting__c 
            WHERE Expense_for_Approval__c IN :reportIds
        ];
    
        // Collect expense IDs from junction objects
        for (Expense_for_Accounting__c expens : junctions) {
            expenseIds.add(expens.Selected_Expense__c);
        }
    
        // Query expenses
        List<Expense__c> curExpenses = [
            Select Id, Reimbursement_Employee__c, Charge__c 
            FROM Expense__c 
            WHERE Id IN :expenseIds
        ];
    
        // Create maps for easy lookup
        Map<Id, Expense__c> idForExpense = new Map<Id, Expense__c>();
        for (Expense__c expense : curExpenses) {
            idForExpense.put(expense.Id, expense);
        }
    
        Map<Id, Employee_Expense_Accounting__c> idForReports = new Map<Id, Employee_Expense_Accounting__c>();
        for (Employee_Expense_Accounting__c report : newReport) {
            idForReports.put(report.Id, report);
        }
    
        // Maps to store junctions related to each report
        Map<Id, List<Expense_for_Accounting__c>> reportToJunctionsMap = new Map<Id, List<Expense_for_Accounting__c>>();
        for (Expense_for_Accounting__c junc : junctions) {
            if (!reportToJunctionsMap.containsKey(junc.Expense_for_Approval__c)) {
                reportToJunctionsMap.put(junc.Expense_for_Approval__c, new List<Expense_for_Accounting__c>());
            }
            reportToJunctionsMap.get(junc.Expense_for_Approval__c).add(junc);
        }
    
        // List to hold updated report objects
        List<Employee_Expense_Accounting__c> updatedReports = new List<Employee_Expense_Accounting__c>();
    
        // Iterate over each report and calculate the sums
        for (Id reportId : reportIds) {
            Employee_Expense_Accounting__c originalReport = idForReports.get(reportId);
            
            // Create a new instance and copy the Id and calculated fields
            Employee_Expense_Accounting__c report = new Employee_Expense_Accounting__c(
                Id = originalReport.Id, // Ensure the Id is set
                Expense_charge_request__c = 0.0,
                Expense_reimbursement_request__c = 0.0
            );
    
            if (reportToJunctionsMap.containsKey(reportId)) {
                for (Expense_for_Accounting__c junc : reportToJunctionsMap.get(reportId)) {
                    Expense__c expense = idForExpense.get(junc.Selected_Expense__c);
                    if (expense != null) {
                        report.Expense_reimbursement_request__c += (expense.Reimbursement_Employee__c != null) ? expense.Reimbursement_Employee__c : 0.0;
                        report.Expense_charge_request__c += (expense.Charge__c != null) ? expense.Charge__c : 0.0;
                    }
                }
            }
    
            updatedReports.add(report);
        }
    
        // Update all the reports in one DML operation
        if (!updatedReports.isEmpty()) {
            update updatedReports;
        }
    }
    
    /**
     * @description Hier wird der Status der Ausgaben basierend auf dem Wert des Genehmigungsfelds geändert.
     * @param newReport 
     */
    public static void changeExpenseStatus(List<Employee_Expense_Accounting__c> newReport){
        Set<Id> reportIds = new Set<Id>();
        Set<Id> expenseIds = new Set<Id>();
        for(Employee_Expense_Accounting__c report: newReport){
            Id currentId = report.Id;
            reportIds.add(currentId);
        }
        List<Expense_for_Accounting__c> junctions = [Select Id, Name, Selected_Expense__c, Expense_for_Approval__c FROM Expense_for_Accounting__c WHERE Expense_for_Approval__c IN: reportIds];
        for(Expense_for_Accounting__c expens: junctions){
            Id curExp = expens.Selected_Expense__c;
            expenseIds.add(curExp);
        }
        List<Expense__c> curExpenses = [Select Id, Name, Stage__c, Employee_v2__c FROM Expense__c WHERE Id IN : expenseIds];
        Map<Id,Expense__c> idForExpense = new Map<Id, Expense__c>();
        Map<Id, Employee_Expense_Accounting__c> idForReports= new Map<Id, Employee_Expense_Accounting__c>();
        for(Expense__c expense: curExpenses){
            Expense__c newExp = expense;
            idForExpense.put(newExp.Id, newExp);
        }
        for(Employee_Expense_Accounting__c report: newReport){
            Employee_Expense_Accounting__c newRep = report;
            idForReports.put(newRep.Id, newRep);
        }
        List<Expense__c> changedExpenses = new List<Expense__c>();
        Expense__c changedExpense = new Expense__c();
        Employee_Expense_Accounting__c report = new Employee_Expense_Accounting__c();
        for(Expense_for_Accounting__c junction: junctions){
            changedExpense = idForExpense.get(junction.Selected_Expense__c);
            report = idForReports.get(junction.Expense_for_Approval__c);
            if((changedExpense.Stage__c == 'Requested' && report.Approve__c == 'Approved') || (changedExpense.Stage__c == 'Declined' && report.Approve__c == 'Approved')){
                        changedExpense.Stage__c = 'Approved';
                        changedExpenses.add(changedExpense);
                    }
                    else if(changedExpense.Stage__c == 'Requested' && report.Approve__c == 'Declined'){  
                        changedExpense.Stage__c = 'Declined'; 
                        changedExpenses.add(changedExpense);
                    }
                    else if(changedExpense.Stage__c == 'Approved' && report.Approve__c == 'Transmitted to tax-advisor'){
                        changedExpense.Stage__c = 'Transmitted to tax-advisor';
                        changedExpenses.add(changedExpense);
                    }
        }
        update changedExpenses;
    }
}