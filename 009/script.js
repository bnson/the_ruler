//-- Load AI
window.speechSynthesis;
let ai;
const voiceEn1 = "Microsoft Eva Mobile - English (United States)";
const voiceEn2 = "Microsoft David - English (United States)";
const voiceEn3 = "Microsoft Zira - English (United States)";
const voiceVn = "Microsoft An - Vietnamese (Vietnam)";

//-- Config
let isPlayEn = true;
let isPlayVn = false;
const isSpeakEnSilence = true;

const names = ["Ann", "Trang"];
const wordsEnNeedReplaceSearch = ["Ha Noi"];
const wordsEnNeedReplaceNew = ["HaNoi"];

// -1 = Page title.
let pageCurrent = -1;
indexEn = -1;
indexVn = -1;

let repeatEn = 3;
let repeatEnCounted = 0;

let speakTextVn = "";
let speakTextEn = "";
let speakTextPronounce = "";

let timer;
let wait = 2000;
let countSeconds = 0;

//====
const FADE_IN = 300;
const TEMPLATE_ITEM_TITLE = '<div class="col-auto px-md-2 bg-white rounded shadow d-flex p-2 m-2 title"><h5 class="p-2">$1</h5></div>';
const TEMPLATE_ITEM_VOCABULARY = '<div class="col p-2 m-2 border border-3 border-dark item-vocabulary" id="item-vocabulary-$1">$2</div>';

//====
const AUDIO_BACKGROUND = "D:/Music/Forest Lullabye - Asher Fulero.mp3";
const VIDEO_BACKGROUND = "D:/Videos/Genshin Impact/Background 2023-01-24 22-07-54.mp4";
const VIDEO_LEFT = "D:/Videos/Genshin Impact/2023-03-14 21-55-30.mp4";

//====
const WEBSITE = ["https://ehosito.com/", "https://engdoc123.blogspot.com"][0];
const YOUTUBE = ["EngLives", "EngDoc123"][0];
const YOUTUBE_FULL_NAME = ["English Lives", "English Documents 123"][0];
const COPYRIGHT = "E-Hosito";

//====
const ROW_1_TITLES = [
    "TIẾNG ANH GIAO TIẾP.",
    "TỔNG HỢP CÁC TỪ VÀ CÂU THÔNG DỤNG NHẤT TRONG TIẾNG ANH GIAO TIẾP → PHẦN 1: 20 TỪ VÀ CÂU."
];

const ROW_2_TITLES = [];


const INFORMATIONS = [
    "Hướng dẫn: Đầu tiên bạn hãy lắng nghe phát âm từ vựng, tiếp sau video sẽ dừng lại một khoảng thời gian vừa đủ để bạn đọc lại.",
];

const INFORMATIONS_SHORT = [
    YOUTUBE_FULL_NAME,
    "Lập lại theo mình nhé.",
    "Bạn có thể xem toàn bộ nội dung trong phần mô tả."
];

//====
const VIDEO_TITLE_EN = "<div><u>" + ROW_1_TITLES[0] + "</u><br>" + ROW_1_TITLES[1] + "</div>";
const VIDEO_TITLE_VN = "";
const VIDEO_VOCABULARIES = "About when?↔Vào khoảng thời gian nào?↔/əˈbaʊt/ /wen/↨Absolutely!↔Chắc chắn rồi!↔/ˌæb.səˈluːt.li/↨Add fuel to the fire.↔Thêm dầu vào lửa.↔/æd/ /ˈfjuː.əl/ /tuː/ /ðiː/ /faɪr/↨After you.↔Sau bạn.↔/ˈæf.tɚ/ /juː/↨Almost!↔Sắp xong rồi!↔/ˈɑːl.moʊst/↨Always the same.↔Luôn luôn giống nhau.↔/ˈɑːl.weɪz/ /ðiː/ /seɪm/↨Ask for it!↔Tự làm tự chịu↔/æsk/ /fɔːr/ /ɪt/↨Be good!↔Ngoan nhé!↔/bɪ/ /ɡʊd/↨Beggars can’t be choosers!↔Người ăn xin không thể là người lựa chọn!↔/ˈbeɡ.ɚ/ /kænt/ /bɪ/ /ˈtʃuː.zi/↨Bored to death!↔Chán muốn chết!↔/bɔːrd/ /tuː/ /deθ/↨Bottom up!↔Hết ly nào.↔/ˈbɑː.t̬əm/ /ʌp/↨Boys will be boys!↔Nó vẫn là con nít thôi!↔/bɔɪ/ /wɪl/ /bɪ/ /bɔɪ/↨Come here.↔Đến đây.↔/kʌm/ /hɪr/↨Come over.↔Ghé chơi.↔/kʌm/ /ˈoʊ.vɚ/↨Congratulations!↔Chúc mừng!↔/kənˌɡrætʃ·əˈleɪ·ʃənz, -ˌɡrædʒ-/↨Dead meat.↔Chết chắc↔/ded/ /miːt/↨Definitely!↔Chắc chắn!↔/ˈdef.ən.ət.li/↨Do as I say.↔Làm như tôi nói.↔/də/ /əz/ /aɪ/ /seɪ/↨Don’t be nosy.↔Đừng tò mò.↔/doʊnt/ /bɪ/ /ˈnoʊ.zi/↨Don’t bother.↔Đừng bận tâm.↔/doʊnt/ /ˈbɑː.ðɚ/".split("↨");
//const VIDEO_VOCABULARIES = "compensation leave for maternity↔nghỉ hưởng chế độ thai sản↔/ˌkɑːm.penˈseɪ.ʃən/ /liːv/ /fɔːr/ /məˈtɝː.nə.t̬i/↨compensation leave for specific holiday↔nghỉ bù cho ngày lễ đặc biệt↔/ˌkɑːm.penˈseɪ.ʃən/ /liːv/ /fɔːr/ /spəˈsɪf.ɪk/ /ˈhɑː.lə.deɪ/↨day-off unregular↔nghỉ bất thường hoặc nghỉ không lý do↔/deɪ/-/ɑːf/ /ʌnˈreɡ.jə.lɚ/↨extra leave for talent and manager↔nghỉ phép thêm cho nhân tài và người quản lý↔/ˈek.strə/ strong /fɔːr/ /liːv/ /ˈmæn.ə.dʒɚ/ /ˈtæl.ənt/↨funeral leave↔nghỉ tang lễ↔/ˈfjuː.nɚ.əl/ /liːv/↨leave for training↔nghỉ để đi đào tạo↔/liːv/ /fɔːr/ /ˈtreɪ.nɪŋ/↨marriage leave↔nghỉ để kết hôn↔/ˈmer.ɪdʒ/ /liːv/↨maternity leave↔nghỉ thai sản cho mẹ↔/məˈtɝː.nə.t̬i/ /liːv/↨menstruation leave↔nghỉ kinh nguyệt↔/ˌmen.struˈeɪ.ʃən/ /liːv/↨paid leave↔nghỉ có lương↔/peɪd/ /liːv/↨paternity leave↔nghỉ thai sản cho bố↔/pəˈtɝː.nə.t̬i/ /liːv/↨sick leave↔nghỉ ốm↔/sɪk/ /liːv/↨trade union leave↔nghỉ phép công đoàn↔/treɪd/ /ˈjuː.njən/ /liːv/↨unpaid leave↔nghỉ phép không lương↔/ʌnˈpeɪd/ /liːv/".split("↨");

//========================
//========================
function loadTitle() {

    if (ROW_1_TITLES.length > 0) {
        ROW_1_TITLES.forEach(function (item, index) {
            //console.log(item, index);
            if (index < ROW_1_TITLES.length - 1) {
                $("#row-1").append(TEMPLATE_ITEM_TITLE.replace("$1", item));
            } else {
                $("#row-1").append(TEMPLATE_ITEM_TITLE.replace("$1", item).replace("col-auto", "col"));
            }
        });        
    }

    if (ROW_2_TITLES.length > 0) {
        ROW_2_TITLES.forEach(function (item, index) {
            //console.log(item, index);
            if (index < ROW_2_TITLES.length - 1) {
                $("#row-2").append(TEMPLATE_ITEM_TITLE.replace("$1", item));
            } else {
                $("#row-2").append(TEMPLATE_ITEM_TITLE.replace("$1", item).replace("col-auto", "col"));
            }
        }); 
    }

    $("#show-title").html((VIDEO_TITLE_EN));

}

function showVocabulary(index) {
    let vocabulary = VIDEO_VOCABULARIES[index].split("↔");

    $("#vocabulary-en").html(vocabulary[0]);
    $("#vocabulary-en").fadeIn(FADE_IN);

    $("#vocabulary-vn").html(vocabulary[1]);
    $("#vocabulary-vn").fadeIn(FADE_IN);

    $("#vocabulary-pronounce").html(vocabulary[2]);
    $("#vocabulary-pronounce").fadeIn(FADE_IN);

    $(".item-vocabulary").removeClass("bg-info text-white font-weight-bold border-info");
    $("#item-vocabulary-" + index).addClass("bg-info text-white font-weight-bold border-info");

}

function loadVocabularyList() {
    showVocabulary(0);

    VIDEO_VOCABULARIES.forEach(function (item, index) {
        item = TEMPLATE_ITEM_VOCABULARY.replace("$1", index).replace("$2", item.split("↔")[0]);
        
        if ((index + 1) % 5 == 0) {
            //item = item.replace("col-2", "col");
            $("#show-vocabulary-list").append(item);
            $("#show-vocabulary-list").append('<div class="w-100"></div>');
        } else {
            $("#show-vocabulary-list").append(item);
        }

        
    });
}

function loadAi() {
    //== LOAD AI ==
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
//========================
//========================
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


//========================
//========================
function load() {
    loadAi();
    loadTitle();
    loadVocabularyList();

    $("#info-1").text(INFORMATIONS_SHORT[0]);
    $("#info-2").text(INFORMATIONS_SHORT[1]);
    $("#info-3").text(INFORMATIONS_SHORT[2]);

    $("#copyright").text(COPYRIGHT);
    $("#youtube").text(YOUTUBE);
    $("#website").text(WEBSITE);
    $('#website').attr('href', WEBSITE);

    $('#background-video source').attr('src', VIDEO_BACKGROUND);
    $('#background-video')[0].load();
    $('#background-video')[0].play();

    $('#left-video source').attr('src', VIDEO_LEFT);
    $('#left-video')[0].load();
    $('#left-video')[0].play();

    $("#playAudio source").attr("src", AUDIO_BACKGROUND);
    $('#playAudio')[0].load();
}


function read() {

    setTimeout(function () {
        if (pageCurrent <= (VIDEO_VOCABULARIES.length - 1)) {
            if (pageCurrent == indexEn && pageCurrent == indexVn) {
                pageCurrent++;

                //-- End page.
                if (pageCurrent > (VIDEO_VOCABULARIES.length - 1)) {
                    $("#vocabulary-en").html("END.");
                    $("#vocabulary-en").fadeIn(FADE_IN);

                    $("#vocabulary-vn").html("KẾT THÚC.");
                    $("#vocabulary-vn").fadeIn(FADE_IN);

                    $("#vocabulary-pronounce").html("/end/");
                    $("#vocabulary-pronounce").fadeIn(FADE_IN);

                    return;
                }

                speakTextEn = VIDEO_VOCABULARIES[pageCurrent].split("↔")[0];
                speakTextVn = VIDEO_VOCABULARIES[pageCurrent].split("↔")[1];
                speakTextPronounce = VIDEO_VOCABULARIES[pageCurrent].split("↔")[2];

                if (pageCurrent >= 0) {
                    showVocabulary(pageCurrent);
                } else {

                }

            }

            if (pageCurrent != indexVn) {
                indexVn++;

                if (isPlayVn) {
                    ai.setVoice(voiceVn);
                    ai.speak(processSpeakTextVn(speakTextVn), 0.5, 0, 1);
                } else {
                    read();
                }

            } else if (pageCurrent != indexEn) {
                console.log("repeatEnCounted: " + repeatEnCounted);
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

                timer = setInterval(setCountSeconds, 1000);
                ai.speak(processSpeakTextEn(speakTextEn), 1, 1, 1);

            }

        } else {

        }

    }, 2000);

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
        wait = countSeconds * 1000;
        if (repeatEnCounted == 3) {
            wait += 700;
        }

        countSeconds = 0;
        clearInterval(timer);
        console.log("wait: " + wait);
        
    }

    setTimeout(function () {
        if (pageCurrent <= (VIDEO_VOCABULARIES.length - 1)) {
            if (pageCurrent == indexEn && pageCurrent == indexVn) {
                if (pageCurrent >= 0) {
                    $("#vocabulary-en").fadeOut(FADE_IN);
                    $("#vocabulary-vn").fadeOut(FADE_IN);
                    $("#vocabulary-pronounce").fadeOut(FADE_IN);
                } else {

                }
            }
        }

        read();
    }, wait);

}

function play() {
    //-- Play background audio.
    var x = document.getElementById("playAudio");
    x.volume = 0.01;
    x.play();

    //-- Hide/Show elements.
    $("#show-title").addClass("d-none");
    $("#show-vocabulary-list").parent().removeClass("d-none");
    $("#area-1").removeClass("d-none");

    //--
    read();
}


//========================
//== PAGE IS READY ==
$(function() {
    load();

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