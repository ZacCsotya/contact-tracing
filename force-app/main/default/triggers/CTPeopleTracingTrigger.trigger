trigger CTPeopleTracingTrigger on People_Tracing__c (before insert, after insert) {

    switch on Trigger.OperationType {
        when BEFORE_INSERT {
            CTPeopleTracingTriggerHandler.beforeUpdate(Trigger.new);
        }
    }
}