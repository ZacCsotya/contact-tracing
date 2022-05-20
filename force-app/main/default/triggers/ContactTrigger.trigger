trigger ContactTrigger on Contact (after update) {

    switch on Trigger.operationType {
        
        when AFTER_INSERT {
            ContactTriggerHelper.afterInsert(Trigger.new);
        }
        when AFTER_UPDATE {
            ContactTriggerHelper.afterUpdate(Trigger.new, Trigger.oldMap);
        }
        when AFTER_DELETE {
            ContactTriggerHelper.afterDelete(Trigger.old);
        }
        when AFTER_UNDELETE {
            ContactTriggerHelper.afterUndelete(Trigger.new);
        }
    }
}