
function getSelectionRect() {
    var sel = document.selection,
            range, rect, height;
        var x = 0,
            y = 0;
        if (sel) {
            if (sel.type != "Control") {
                range = sel.createRange();
                range.collapse(true);
                x = range.boundingLeft;
                y = range.boundingTop;
                height = range.boundingHeight;
            }
        } else if (window.getSelection) {
            sel = window.getSelection();
            if (sel.rangeCount) {
                range = sel.getRangeAt(0).cloneRange();
                if (range.getClientRects().length > 0) {
                    range.collapse(true);
                    rect = range.getClientRects()[0];
                    x = rect.left;
                    y = rect.top;
                    height = rect.height;
                }
                // Fall back to inserting a temporary element
                if (x === 0 && y === 0) {
                    var span = document.createElement("span");
                    if (span.getClientRects) {
                        // Ensure span has dimensions and position by
                        // adding a zero-width space character
                        span.appendChild(document.createTextNode("\u200b"));
                        range.insertNode(span);
                        rect = span.getClientRects()[0];
                        x = rect.left;
                        y = rect.top;
                        height = rect.height;
                        var spanParent = span.parentNode;
                        spanParent.removeChild(span);
                        // Glue any broken text nodes back together
                        spanParent.normalize();
                    }
                }
            }
        }
        return {
            x: x,
            y: y,
            h: height
        };
}

function scrollToVisible() {
    var contentEle = document.getElementById("content");
    var contentHeight = contentEle.clientHeight;
    var webViewHeight = document.body.clientHeight;

    if (contentHeight > webViewHeight) {
        var selRect = getSelectionRect();
        if (selRect.y < window.pageYOffset) {
            window.scrollTo(0, selRect.y);
        }
        else if( selRect.y - window.pageYOffset > webViewHeight) {
            window.scrollTo(0, selRect.y - webViewHeight);
        }
    }
}

document.addEventListener("touchend", function(e) {
    scrollToVisible();    
  },false);

