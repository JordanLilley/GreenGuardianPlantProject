trigger gardenObjectTrigger on CAMPX__Garden__c (before insert, after insert, before update, after update) {
    if (Trigger.isBefore && Trigger.isInsert) {
        // Set default values for the new garden record
        for (CAMPX__Garden__c gardenRecord : Trigger.new) {
            if (gardenRecord.CAMPX__Status__c == null) {
                gardenRecord.CAMPX__Status__c = 'Awaiting Resources';
            }
            if (gardenRecord.CAMPX__Max_Plant_Count__c == null) {
                gardenRecord.CAMPX__Max_Plant_Count__c = 100;
            }
            if (gardenRecord.CAMPX__Minimum_Plant_Count__c == null) {
                gardenRecord.CAMPX__Minimum_Plant_Count__c = 1;
            }
            if (gardenRecord.CAMPX__Total_Plant_Count__c == null) {
                gardenRecord.CAMPX__Total_Plant_Count__c = 0;
            }
            if (gardenRecord.CAMPX__Total_Unhealthy_Plant_Count__c == null) {
                gardenRecord.CAMPX__Total_Unhealthy_Plant_Count__c = 0;
            }
            if (gardenRecord.CAMPX__Manager__c != null) {
                gardenRecord.CAMPX__Manager_Start_Date__c = System.today();
            }
        }
    }

    if (Trigger.isAfter && Trigger.isInsert) {
        List<Task> tasksToInsert = new List<Task>();

        for (CAMPX__Garden__c gardenRecord : Trigger.new) {
            if (gardenRecord.CAMPX__Manager__c != null) {
                if (Schema.sObjectType.Task.isCreateable()) {
                    Task newTask = new Task(
                        Subject = 'Acquire Plants',
                        OwnerId = gardenRecord.CAMPX__Manager__c,
                        WhatId = gardenRecord.Id // Now the Id is available
                    );
                    tasksToInsert.add(newTask);
                } else {
                    // Handle lack of permissions (e.g., log an error or notify an admin)
                    System.debug('User does not have permission to create Task records.');
                }
            }
        }

        if (!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }
    }

    if (trigger.isUpdate && trigger.isAfter) {
        List<Task> tasksToInsert = new List<Task>();

        for (CAMPX__Garden__c gardenRecord : Trigger.new) {
            List<Task> listOfTasks = [SELECT Id, OwnerId, Status, Subject FROM Task WHERE WhatId = :gardenRecord.Id];
            CAMPX__Garden__c oldGardenRecord = Trigger.oldMap.get(gardenRecord.Id);
            if (gardenRecord.CAMPX__Manager__c != null && oldGardenRecord.CAMPX__Manager__c == null) {
                    Task newTask = new Task(
                        Subject = 'Acquire Plants',
                        OwnerId = gardenRecord.CAMPX__Manager__c,
                        WhatId = gardenRecord.Id // Now the Id is available
                    );
                    tasksToInsert.add(newTask);
            }

            if (gardenRecord.CAMPX__Manager__c != null && oldGardenRecord.CAMPX__Manager__c != gardenRecord.CAMPX__Manager__c) {
                for (Task taskToUpdate : listOfTasks) {
                    if (taskToUpdate.Status != 'Completed') {
                        taskToUpdate.OwnerId = gardenRecord.CAMPX__Manager__c;
                        update taskToUpdate;
                    }
                }
            }

            if(oldGardenRecord.CAMPX__Manager__c != null && gardenRecord.CAMPX__Manager__c == null) {
                for (Task taskToDelete : listOfTasks) {
                    if (taskToDelete.Status != 'Completed' && taskToDelete.Subject == 'Acquire Plants') {
                        delete taskToDelete;
                    }
                }
            }
        }
        if (!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }
    }

    // Before update logic
    if (trigger.isUpdate && trigger.isAfter) {
        if (Schema.sObjectType.CAMPX__Garden__c.isUpdateable()) {
            List<CAMPX__Garden__c> gardensToUpdate = new List<CAMPX__Garden__c>();
            for (CAMPX__Garden__c gardenRecord : Trigger.new) {
                CAMPX__Garden__c oldGardenRecord = Trigger.oldMap.get(gardenRecord.Id);
                if (gardenRecord.CAMPX__Manager__c != null && oldGardenRecord.CAMPX__Manager__c != gardenRecord.CAMPX__Manager__c) {
                    CAMPX__Garden__c gardenToUpdate = new CAMPX__Garden__c(
                        Id = gardenRecord.Id,
                        CAMPX__Manager_Start_Date__c = System.today()
                    );
                    gardensToUpdate.add(gardenToUpdate);
                }
            }
            if (!gardensToUpdate.isEmpty()) {
                update gardensToUpdate;
            }
        } else {
            System.debug('User does not have permission to update CAMPX__Garden__c records.');
        }
    }
}