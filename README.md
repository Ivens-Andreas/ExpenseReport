Dieses Projekt wurde als Salesforce Anwendung realisiert.
Hierbei ging es darum, den Mitarbeitern zu ermöglichen Ihre Spesen, als einheitliche Spesenabrechnung im Corporate Identity des Unternehmens einreichen zukönnen.
Die Spesendaten sollten in Salesforce gespeichert werden können, dafür wurde in Salesforce ein Benutzerdefiniertes-Objekt "Spesenobjekt" angelegt.
Dieses Objekt enthält festgelegte Felder wie z.B. Mitarbeiter Name, Start- und Enddatum des Abrechnungszeitraumes, Summe der gesamten Ausgaben und Summe der gesamt Erstatung.
Es wurde ein Genehmigungsprozess implementiert, bei dem nur Berechtigte Personen Änderungen am Status der Genehmigung für die Abrechnung vornehmen können.
Dies wurde in Salesforce mit einer Validierungsregel umgesetzt.

Im Spesenobjekt werden alle für die Spesenabrechung notwendigen Daten gespeichert.
Der so generierte Datensatz, kann dann in einer Visualforce Page als Spesenabrechnung angesehen und als PDF heruntergeladen und gespeichert werden.
