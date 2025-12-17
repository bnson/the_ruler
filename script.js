const TITLE1 = "ENGLISH WRITING SAMPLES.<br><font color='#777777'>(VĂN MẪU TIẾNG ANH.)</font>";
const TITLE2 = "ALONG THE HIGHWAY.<br><font color='#777777'>(DỌC THEO ĐƯỜNG CAO TỐC.)</font>";
const TITLE3 = "";
const TITLE4 = "";
const TITLE5 = "";

const CONTENT_END_EN = "<div style='font-size:55px'>END.</div>";
const CONTENT_END_VN = "<div style='font-size:55px'>KẾT THÚC.</div>";

const AUDIO_BACKGROUND = "E:/Music/Forest Lullabye - Asher Fulero.mp3";

const VIDEO_BACKGROUND = "E:/Videos/Background/001_small-house-in-forest_3840x2160.mp4";
const VIDEO_LEFT = "E:/Videos/Background/001_small-house-in-forest_3840x2160.mp4";

const INPUT_TEXT_ENGLISH = "<div style='padding-top:10px;font-size:55px'>ALONG THE HIGHWAY.</div>↨Jim’s father likes to drive Mrs. Green and the children out into the country on sunny days.↨The road is long, and they see green fields and tall trees along the way.↨Everyone enjoys looking out the window as the car moves down the highway.↨When they go on an all-day trip, the Greens always carry a basket filled with food.↨Inside the basket are sandwiches, fruit, and juice for lunch.↨At noon, they stop near a big tree to eat and to rest in the cool shade.↨The children laugh and play while the parents talk and relax.↨Jim’s uncle is a farmer who works hard every day.↨He grows vegetables and takes them to the market in his truck.↨Today, he invited the Greens to have a picnic in his woods.↨The woods are quiet and full of birds singing.↨After lunch, they walk among the trees and enjoy the fresh air.↨It is a happy day for everyone.";

const INPUT_TEXT_VIETNAMESE = "<div style='padding-top:10px;font-size:55px'>DỌC THEO ĐƯỜNG CAO TỐC.</div>↨Bố của Jim thích lái xe chở bà Mrs. Green và các em nhỏ ra vùng nông thôn vào những ngày nắng đẹp.↨Con đường dài, và họ nhìn thấy những cánh đồng xanh cùng những hàng cây cao dọc đường.↨Ai cũng thích ngắm cảnh qua cửa sổ khi chiếc xe chạy trên đường cao tốc.↨Khi đi chơi cả ngày, gia đình Green luôn mang theo một giỏ đầy thức ăn.↨Trong giỏ có bánh mì kẹp, trái cây và nước uống cho bữa trưa.↨Đến trưa, họ dừng lại dưới một cây lớn để ăn và nghỉ ngơi trong bóng mát.↨Các em nhỏ cười và chơi đùa trong khi bố mẹ trò chuyện và thư giãn.↨Chú của Jim là một nông dân làm việc chăm chỉ mỗi ngày.↨Ông trồng rau và chở chúng ra chợ bằng chiếc xe tải của mình.↨Hôm nay, ông mời gia đình Green đến dã ngoại trong khu rừng của ông.↨Khu rừng yên tĩnh và đầy tiếng chim hót.↨Sau bữa trưa, họ đi dạo giữa những hàng cây và tận hưởng không khí trong lành.↨Đó là một ngày thật vui vẻ cho tất cả mọi người.";

const FADE_IN = 300;
const VOLUME_BACKGROUND_MUSIC = 0.01;

//-- Load AI
window.speechSynthesis;
let ai;
const voiceEn1 = "Microsoft Zira - English (United States)";
const voiceEn2 = "Microsoft David - English (United States)";
const voiceEn3 = "Microsoft Eva Mobile - English (United States)";
const voiceVn = "Microsoft An - Vietnamese (Vietnam)";

//-- Config
const isPlayVn = false;
const isPlayEn = true;

const isSpeakEnSilence = true;

const names = ["Ann", "Trang"];
const wordsEnNeedReplaceSearch = ["Ha Noi"];
const wordsEnNeedReplaceNew = ["HaNoi"];

let arrTextEnglish = INPUT_TEXT_ENGLISH.split("↨");
let arrTextVietnamese = INPUT_TEXT_VIETNAMESE.split("↨");

let index = -1;

let indexEn = -1;
let indexVn = -1;

let repeatEn = 1;
let repeatEnCounted = 0;

let speakTextVn = "";
let speakTextEn = "";

let timer;
//let wait = 500;
let wait = 0;
let countSeconds = 0;
//========================
//========================
function load() {
    ai = new AI("Sliver");

    if (ai.getStatus() === 1) {
        console.log(ai.getStatusMessage());

        //====
        ai.setVoice(voiceEn1);

        //====
        let utterOnboundary = event => {
            speechSynthesisUtteranceOnoundary(event);
        };
        ai.addUtterOnBoundaryEvent(utterOnboundary);

        let utterOnEnd = event => {
            speechSynthesisUtteranceOnEnd(event);
        };
        ai.addUtterOnEndEvent(utterOnEnd);

        //====

    } else {
        console.log(ai.getStatusMessage());
    }
}

function trimSpace(str) {
    return str.trim().replace(/\s+/g, ' ');
}

function showText(text) {
    let rs = trimSpace(text.replace(/(^[^:]+: )/, "<b>$1</b><br>"));
    return rs;
}

function processSpeakTextVn(text) {
    let rs = trimSpace(text.replace(/(^[^:]+: )/, ""));
    return rs;
}

function processSpeakTextEn(text) {
    let rs = trimSpace(text.replace(/(^[^:]+: )/, ""));

    for (let i = 0; i < wordsEnNeedReplaceSearch.length; i++) {
        rs = rs.replaceAll(wordsEnNeedReplaceSearch[i], wordsEnNeedReplaceNew[i]);
    }

    return rs;
}

function setCountSeconds() {
    countSeconds++;
}

function read() {

    setTimeout(function () {
        if (index <= (arrTextEnglish.length - 1)) {
            if (index == indexEn && index == indexVn) {
                index++;

                if (index > (arrTextEnglish.length - 1)) {
                    $("#text-english").html(CONTENT_END_EN);
                    $("#text-english").fadeIn(FADE_IN);

                    $("#text-vietnamese").html(CONTENT_END_VN);
                    $("#text-vietnamese").fadeIn(FADE_IN);
                    return;
                }

                speakTextEn = arrTextEnglish[index].replace(/<\/?[^>]+(>|$)/g, "");;
                speakTextVn = arrTextVietnamese[index].replace(/<\/?[^>]+(>|$)/g, "");;
				

				if (index == 1) {
					$("#text-english").html(speakTextEn);
					$("#text-english").fadeIn(FADE_IN);
					$("#text-vietnamese").html(speakTextVn);
					$("#text-vietnamese").fadeIn(FADE_IN);
				} else if (index > 1) {
                    $("#text-english").html(showText(speakTextEn));
                    $("#text-english").fadeIn(FADE_IN);

                    $("#text-vietnamese").html(showText(speakTextVn));
                    $("#text-vietnamese").fadeIn(FADE_IN);
                } else {

                }
				
				console.log(speakTextEn);

            }

            if (index != indexVn) {
                indexVn++;

                if (isPlayVn) {
                    ai.setVoice(voiceVn);
                    ai.speak(processSpeakTextVn(speakTextVn), 0.5, 0, 1);
                } else {
                    read();
                }

            } else if (index != indexEn) {
                repeatEnCounted++;

                if (repeatEnCounted == 1) {
                    ai.setVoice(voiceEn1);
                }
                if (repeatEnCounted == 2) {
                    ai.setVoice(voiceEn2);
                }
                if (repeatEnCounted == 3) {
                    ai.setVoice(voiceEn3);
                }

                if (repeatEnCounted == repeatEn) {
                    indexEn++;
                    repeatEnCounted = 0;
                }

                //timer = setInterval(setCountSeconds, 500);
				timer = setInterval(setCountSeconds, 5000);
                ai.speak(processSpeakTextEn(speakTextEn), 1, 1.2, 0.7);

            }

        } else {

        }

    }, 1000);

}

function speechSynthesisUtteranceOnoundary(event) {
    //console.log(event.name);
    if (event.name == "sentence") {
        let text = getTextAt(event.target.text, event.charIndex);
        console.log(text);
    }
}

function getTextAt(str, pos) {
    return str;
}

function getWordAt(str, pos) {
    // Perform type conversions.
    str = String(str);
    pos = Number(pos) >>> 0;

    // Search for the word's beginning and end.
    let left = str.slice(0, pos + 1).search(/\S+$/);
    let right = str.slice(pos).search(/\s/);

    // The last word in the string is a special case.
    // else Return the word, using the located bounds to extract it from the string.
    return right < 0 ? str.slice(left) : str.slice(left, right + pos);
}

function speechSynthesisUtteranceOnEnd(event) {
    if (isSpeakEnSilence) {
        console.log("repeatEnCounted: " + repeatEnCounted);

        wait = countSeconds * 300;
        if (repeatEnCounted == 0) {
            wait += 3500;
        }
        countSeconds = 0;
        clearInterval(timer);
        console.log("wait: " + wait);
        
    }

    setTimeout(function () {
        if (index <= (arrTextEnglish.length - 1)) {
            if (index == indexEn && index == indexVn) {
                if (index == 0) {
                    $("#text-english").fadeOut(FADE_IN);
                    $("#text-vietnamese").fadeOut(FADE_IN);
                } else if (index != 0) {
                    $("#text-english").fadeOut(FADE_IN);
                    $("#text-vietnamese").fadeOut(FADE_IN);
                } else {

                }
            }
        }

        read();
    }, wait);

}

function play() {
    var x = document.getElementById("playAudio");
    x.volume = VOLUME_BACKGROUND_MUSIC;
    x.play();

    //arrTextEnglish[0] = "Listen and Repeat.";
    //arrTextVietnamese[0] = "Lắng nghe và đọc lại.";
    console.log(arrTextEnglish);
    read();
}


//========================
//== PAGE IS READY ==
$(function() {
    load();

    $("#title1").html(TITLE1);
    $("#title2").html(TITLE2);
		
    $("#title3").html(TITLE3);
	if (TITLE3 == "") {
		$("#title3").parent().parent().addClass("d-none");
	}
	
    $("#title4").html(TITLE4);
	if (TITLE4 == "") {
		$("#title4").parent().parent().addClass("d-none");
	}
	
    $("#title5").html(TITLE5);
	if (TITLE5 == "") {
		$("#title5").parent().parent().addClass("d-none");
	}	

    //$("#text-english").html("<b>" + arrTextEnglish[0] + "</b>");
    $("#text-english").html(("<b>" + arrTextEnglish[0] + "</b>"));
    $("#text-vietnamese").html("<b>" + arrTextVietnamese[0] + "</b>");

    $('#background-video source').attr('src', VIDEO_BACKGROUND);
    $('#background-video')[0].load();
    $('#background-video')[0].play();

    $('#left-video source').attr('src', VIDEO_LEFT);
    $('#left-video')[0].load();
    $('#left-video')[0].play();
	$('#left-video')[0].currentTime = 0;

    $("#playAudio source").attr("src", AUDIO_BACKGROUND);
    $('#playAudio')[0].load();
    //$('#playAudio')[0].play();

    $("body").on("keydown", function (e) {
        //console.log(e.which);
        if (e.which == 113) {
            play();
        }
    });

});

//== PAGE BEFORE UNLOAD ==
$(window).on('beforeunload', function () {
    ai.getSynth().cancel();
    ai = null;
});

//========================
//========================