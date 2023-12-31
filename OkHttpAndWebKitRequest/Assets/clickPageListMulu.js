let a_List = document.querySelectorAll("a");
var regular_hiddenElement = new RegExp("(点击|中间|隐藏|展开|章节){2,}", "i");
var aElement;
for (let i = 0; i < a_List.length; i++) {
    let attributes=a_List[i].attributes;
    if ((a_List[i].href.includes('javascript') || a_List[i].getAttribute("onclick"))
        &&regular_hiddenElement.test(a_List[i].innerText)) {
        aElement=a_List[i];
        break;
    }
}
if(aElement){
    aElement.click();
    aElement;
}else{
    let button_List = document.querySelectorAll("input[type^=button]");
    for (let i = 0; i < button_List.length; i++) {
        if (regular_hiddenElement.test(button_List[i].value)) {
            button_List[i].click();
            button_List[i];
            break;
        }
    }
}
