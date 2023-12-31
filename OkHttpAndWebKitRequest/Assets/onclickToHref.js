var regular_NextChapter = new RegExp("(下(\\s)*?.{0,1}(\\s)*?(章|篇|页|回))|(翻(\\s)*?下(\\s)*?(章|篇|页|回))|(后(\\s)*?.{0,1}(\\s)*?(章|篇|页|回))|(Next(\\s)*?Chapter)|接着看", "i");
var a_List = document.querySelectorAll("a[href^=javascript]");
var aElement;
for (let i = 0; i < a_List.length; i++) {
   if (regular_NextChapter.test(a_List[i].innerText)) {
       aElement=a_List[i];
       break;
   }
}
if(aElement){
  var regular_href = new RegExp("(window|self|this|parent|top){0,1}[.]{0,1}location.href\\s{0,}=\\s{0,}", "gi");
  var OKHTTP_jump_link;
  var jscode_List = document.getElementsByTagName('script');
  for (let i = 0; i < jscode_List.length; i++) {
   if(jscode_List[i].src.length==0 && jscode_List[i].innerText.length>1){
          jscode_List[i].innerText=jscode_List[i].innerText.replace(regular_href,'OKHTTP_jump_link = ');
   }
}
   if(aElement.getAttribute("href")){
        var js_href_value = aElement.getAttribute("href");
          js_href_value=js_href_value.replace(regular_href,'OKHTTP_jump_link = ');
           eval(js_href_value);
   }
   if(aElement.getAttribute("onclick")){
        var js_onclick_value = aElement.getAttribute("onclick");
        js_onclick_value=js_onclick_value.replace(regular_href,'OKHTTP_jump_link = ');
        eval(js_onclick_value);
   }
   if(OKHTTP_jump_link){
      aElement.onclick=null;
      aElement.href=OKHTTP_jump_link;
      aElement.setAttribute('href', OKHTTP_jump_link);
      aElement.removeAttribute("onclick");
   }
}
