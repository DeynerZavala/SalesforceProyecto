public with sharing class CaseTriggerRepository {
    public static void validateUniqueSubjectPerUser(List<Case> newCaseList) {
        if (newCaseList == null || newCaseList.isEmpty()) {
            return;
        }

        Set<String> subjectSet = new Set<String>();
        Set<Id> contactIdSet = new Set<Id>();
        Map<String, Integer> keyCountMap = new Map<String, Integer>();
        Set<Id> newCaseIds = new Set<Id>();
        for (Case c : newCaseList) {
            if (c.ContactId == null || c.Subject == null) continue;
            String key = c.Subject.trim().toLowerCase() + '###' + c.ContactId;
            keyCountMap.put(key, keyCountMap.containsKey(key) ? keyCountMap.get(key) + 1 : 1);
            subjectSet.add(c.Subject.trim());
            contactIdSet.add(c.ContactId);
            if(c.Id != null) {
                newCaseIds.add(c.Id);
            }
        }

        if (subjectSet.isEmpty() || contactIdSet.isEmpty()) {
            return;
        }
        List<Case> existingCases = [
            SELECT Id, Subject, ContactId 
            FROM Case 
            WHERE Subject IN :subjectSet
            AND ContactId IN :contactIdSet
            AND Id NOT IN :newCaseIds
        ];
        String console ;
        Set<String> existingCombinations = new Set<String>();
        Set<String> idUpdateSame =new Set<String> ();
        for (Case c : existingCases) {
            String key = c.Subject.trim().toLowerCase() + '###' + c.ContactId;
            console +=  c.Id;
            existingCombinations.add(key);
        }

        Set<String> seen = new Set<String>();
        for (Case c : newCaseList) {
            if (c.ContactId == null || c.Subject == null) continue;

            String key = c.Subject.trim().toLowerCase() + '###' + c.ContactId;
            if (existingCombinations.contains(key)) {
                c.Subject.addError('Ya existe un caso con ese asunto para este usuario.');
            } else if (keyCountMap.get(key) > 1) {
                if (!seen.contains(key)) {
                    seen.add(key);
                } else {
                    c.Subject.addError('Ya existe un caso en la lista con ese asunto para este usuario.');
                }
            }
        }
    }
}
