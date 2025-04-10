trigger gardenObjectTrigger on CAMPX__Garden__c (before insert) {
    for (CAMPX__Garden__c gardenRecord : Trigger.new) {
        if (trigger.isBefore == true && trigger.isInsert == true) {
            // Set default values for the new garden record
            if (gardenRecord.CAMPX__Status__c == null){
                gardenRecord.CAMPX__Status__c = 'Awaiting Resources';
            }
            if (gardenRecord.CAMPX__Max_Plant_Count__c == null){
                gardenRecord.CAMPX__Max_Plant_Count__c = 100;
            }
            if (gardenRecord.CAMPX__Minimum_Plant_Count__c == null){
                gardenRecord.CAMPX__Minimum_Plant_Count__c = 1;
            }
            if (gardenRecord.CAMPX__Total_Plant_Count__c == null){
                gardenRecord.CAMPX__Total_Plant_Count__c = 0;
            }
            if (gardenRecord.CAMPX__Total_Unhealthy_Plant_Count__c == null){
                gardenRecord.CAMPX__Total_Unhealthy_Plant_Count__c = 0;
            }
        }
    }
}