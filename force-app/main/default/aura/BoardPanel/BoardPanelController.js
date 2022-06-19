({ 
    startGame : function(component, event, helper) {
        // access ComboBox
        let gameModeComboBox = component.find("gameMode");
        
        // access the value of the ComboBox    
        let selectedValue = gameModeComboBox.get('v.value');

        const selectedMode = component.get("v.selectedMode");
        // updated selectedMode attribute
        component.set('v.selectedMode', selectedValue);
        if(selectedMode) {
            const boardComp = component.find("boardComp");
            boardComp.startGame();
        }
    },

    reshuffleBoard : function(component, event, helper) {
        const boardComp = component.find("boardComp");
        boardComp.reshuffleBoard();
        component.set("v.reshuffleDisabled", true);
    },

    onResultHandler : function(component, event, helper) {
        const result = event.getParam('result');
        if(result === "Win") {
            component.set("v.reshuffleDisabled", true);
            helper.showToast('You Win', 'Hooray!!', 'success');
        } else {
            component.set("v.reshuffleDisabled", false);
            helper.showToast('You Lose', 'Reshuffle the board to keep playing.', 'error');
        }
        helper.addResultRecord(component, result);
    },
})
