var html=document.getElementsByTagName('html')[0].outerHTML;
function getBg(element)
{
    if (typeof element == "string") element = document.getElementById(element);
    if (!element) return;
    cssProperty = "backgroundColor";
    mozillaEquivalentCSS = "background-color";
    if (element.currentStyle)
        var actualColor = element.currentStyle[cssProperty];
    else
    {
        var cs = document.defaultView.getComputedStyle(element, null);
        var actualColor = cs.getPropertyValue(mozillaEquivalentCSS);
    }
    if (actualColor == "transparent" && element.parentNode)
        return arguments.callee(element.parentNode);
    if (actualColor == null)
        return "#ffffff";
    else
        return actualColor;
}
function getColorBg(element)
{
    if (typeof element == "string") element = document.getElementById(element);
    if (!element) return;
    cssProperty = "color";
    mozillaEquivalentCSS = "color";
    if (element.currentStyle)
        var actualColor = element.currentStyle[cssProperty];
    else
    {
        var cs = document.defaultView.getComputedStyle(element, null);
        var actualColor = cs.getPropertyValue(mozillaEquivalentCSS);
    }
    if (actualColor == "transparent" && element.parentNode)
        return arguments.callee(element.parentNode);
    if (actualColor == null)
        return "#ffffff";
    else
        return actualColor;
}

function traverseNodes(node){
    if(document.body !=node){
        try{
            //元素隐藏，删除.包括script
            if(window.getComputedStyle(node,null).display=="none"){
                html=html.replace(node.outerHTML,"");
            }
        }catch(e){}
        
        try{
            var nodecolor=getColorBg(node);
            //元素颜色和背景颜色一样，删除；元素颜色和父元素的背景颜色一样，删除||getBg(node.parentNode)==nodecolor
            if(getBg(node) ==nodecolor){
                html=html.replace(node.outerHTML,"");
            }
        }catch(e){}
    }
    if(node && node.hasChildNodes){
        //得到所有的子节点
        var sonnodes = node.childNodes;
        //遍历所哟的子节点
        for (var i = 0; i < sonnodes.length; i++) {
            //得到具体的某个子节点
            var sonnode = sonnodes.item(i);
            //递归遍历
            traverseNodes(sonnode);
        }
    }
}
traverseNodes(document.body);
html;


