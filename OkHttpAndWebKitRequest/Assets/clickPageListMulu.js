let a_List = document.querySelectorAll("a[href^='javascript'");
var aElement;
for (let i = 0; i < a_List.length; i++) {
    if (a_List[i].innerText.includes('点击查看') && a_List[i].innerText.includes('中间隐藏的')) {
        aElement=a_List[i];
    }
}
if(aElement){
    aElement.click();
    aElement;
}

