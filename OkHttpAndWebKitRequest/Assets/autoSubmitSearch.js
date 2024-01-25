let inputList = document.querySelectorAll("input[type='text'],input[type='search']");
var inputElement;
for (let i = 0; i < inputList.length; i++) {
    if (inputList[i].value.includes('搜')
        || inputList[i].placeholder.includes('搜')
        || inputList[i].placeholder.includes('关键词')
        ) {
        inputElement=inputList[i];
        inputElement.value='Diversity';
    }
}
if(inputElement){
    let buttonList = document.querySelectorAll("button[type='button'],button[type='submit'],input[type='submit']");
    var buttonElement;
    for (let i = 0; i < buttonList.length; i++) {
        if(buttonList[i].compareDocumentPosition(inputElement)==2){
            buttonElement=buttonList[i];
        }
    }
    if(buttonElement){
        buttonElement.click();
    }
}
