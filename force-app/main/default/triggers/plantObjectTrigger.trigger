trigger plantObjectTrigger on CAMPX__Plant__c (before insert) {
    // Query related CAMPX__Garden__c fields for the plants being inserted
    Map<Id, CAMPX__Garden__c> gardenMap = new Map<Id, CAMPX__Garden__c>();
    for (CAMPX__Plant__c plantRecord : Trigger.new) {
        if (plantRecord.CAMPX__Garden__c != null) {
            gardenMap.put(plantRecord.CAMPX__Garden__c, null);
        }
    }

    if (!gardenMap.isEmpty()) {
        gardenMap.putAll([
            SELECT Id, CAMPX__Sun_Exposure__c
            FROM CAMPX__Garden__c
            WHERE Id IN :gardenMap.keySet()
        ]);
    }

    // Set default values for the new plant records
    for (CAMPX__Plant__c plantRecord : Trigger.new) {
        if (Trigger.isBefore && Trigger.isInsert) {
            if (plantRecord.CAMPX__Soil_Type__c == null) {
                plantRecord.CAMPX__Soil_Type__c = 'All Purpose Potting Soil';
            }
            if (plantRecord.CAMPX__Water__c == null) {
                plantRecord.CAMPX__Water__c = 'Once Weekly';
            }
            if (plantRecord.CAMPX__Sunlight__c == null) {
                if (plantRecord.CAMPX__Garden__c != null && gardenMap.containsKey(plantRecord.CAMPX__Garden__c)) {
                    CAMPX__Garden__c relatedGarden = gardenMap.get(plantRecord.CAMPX__Garden__c);
                    if (relatedGarden != null && relatedGarden.CAMPX__Sun_Exposure__c != null) {
                        plantRecord.CAMPX__Sunlight__c = relatedGarden.CAMPX__Sun_Exposure__c;
                    } else {
                        plantRecord.CAMPX__Sunlight__c = 'Partial Sun';
                    }
                } else {
                    plantRecord.CAMPX__Sunlight__c = 'Partial Sun';
                }
            }
        }
    }
}