({
    doInit : function(component, event, helper) {
        console.log('Initialization completed');

        // get mode
        const gameMode = component.get("v.mode");
        let column = 0;
        if(gameMode && gameMode === "hard"){
            column = 6;
        } else if(gameMode === "medium"){
            column = 4;
        } else{
            column = 3;
        }
        
        // get block width/size
        let blockSize = 12/column;
        component.set("v.blockSize", blockSize);
        // build a list of 100 words
        const words = helper.getWords(column * column);
        component.set("v.words", words);
        // get win word
        const winWord = helper.getWinWord(words);
        component.set("v.winWord", winWord);
        // reset the board
        helper.resetBoard(component);
    },

    blockClickHandler : function(component, event, helper) {
        let clickCount = component.get("v.clickCount") + 1;
        const value = event.getParam("value");

        if(value === component.get("v.winWord")) {
            // user win
            component.set("v.result", "YOU WIN");
            console.log("You win");
            helper.disableBoard(component);
            helper.fireResultEvent("Win");
        } else if(clickCount === 3) {
            // user lose
            component.set("v.result", "YOU LOSE");
            console.log("You lose");
            helper.disableBoard(component);
            helper.fireResultEvent("Lose");
        }
        // set click count
        component.set("v.clickCount", clickCount);
    },

    reshuffleBoard : function(component, event, helper) {
    const words = component.get("v.words");
    const randomizedWords = helper.randomizeArray(words);
    component.set("v.words", randomizedWords);
    helper.resetBoard(component);
    }
})
