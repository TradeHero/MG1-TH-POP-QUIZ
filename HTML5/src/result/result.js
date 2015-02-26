//UI auto-resizing/layouting
var baseContainer = document.getElementById("base-container");
var selfBox = document.getElementById("selfBox");
var awayBox = document.getElementById("awayBox");
var selfAvatar = document.getElementById("selfAvatar");
var awayAvatar = document.getElementById("awayAvatar");
var versusSpan = document.getElementById("versusSpan");
var resultTable = document.getElementById("resultTable");
var awayHintsUsed = document.getElementById("awayHintsUsed");
var awayWinningStreak = document.getElementById("awayWinningStreak");
var awayTotalScore = document.getElementById("awayTotalScore");

/////////////////// BASE ///////////////////
var baseHeight = window.innerHeight;
var baseWidth = window.innerHeight * 0.75;
baseContainer.style.height = "100%";
baseContainer.style.width = baseWidth + "px";

/////////////////// SELF BOX ///////////////////

var selfAwayWHRatio = 258 / 121;
var selfBoxWidth = baseWidth * 0.4;
var selfBoxHeight = selfBoxWidth / selfAwayWHRatio;
selfBox.style.width = selfBoxWidth + 'px';
selfBox.style.height = selfBoxHeight + 'px';

var selfAwayBoxTop = baseHeight * 0.1;
var selfBoxLeft = baseHeight * 0.03;
selfBox.style.top = selfAwayBoxTop + 'px';
selfBox.style.left = selfBoxLeft + 'px';

///////// self avatar ///////
var selfAvatarTop = selfBoxHeight * 0.1;
var selfAvatarLeft = selfBoxWidth * 0.05;
selfAvatar.style.top = selfAvatarTop + 'px';
selfAvatar.style.left = selfAvatarLeft + 'px';

var selfAvatarHeight = selfBoxHeight * 0.7;
selfAvatar.style.width = selfAvatarHeight + 'px';
selfAvatar.style.height = selfAvatarHeight + 'px';

if (selfAvatarUrl != null) {
    selfAvatar.style.background = 'url(\'' + selfAvatarUrl + '\')';
    selfAvatar.style.backgroundSize = 'cover';
}

//username span
var selfUserNameSpan = document.getElementById('selfUserName');
var selfUserNameSpanWidth = 0.6 * selfBoxWidth;
var selfUserNameSpanHeight = 0.1 * selfBoxHeight;
selfUserNameSpan.style.width = selfUserNameSpanWidth + 'px';
selfUserNameSpan.style.height = selfUserNameSpanHeight + 'px';

var selfUserNameSpanTop = selfBoxHeight * 0.25;
var selfUserNameSpanLeft = selfBoxWidth * 0.05 + selfAvatarHeight;
selfUserNameSpan.style.top = selfUserNameSpanTop + 'px';
selfUserNameSpan.style.left = selfUserNameSpanLeft + 'px';
/////////////////// AWAY BOX ///////////////////

var awayBoxWidth = baseWidth * 0.4;
var awayBoxHeight = awayBoxWidth / selfAwayWHRatio;
awayBox.style.width = awayBoxWidth + 'px';
awayBox.style.height = awayBoxHeight + 'px';

var awayBoxLeft = 4 * selfBoxLeft + selfBoxWidth;
awayBox.style.top = selfAwayBoxTop + 'px';
awayBox.style.left = awayBoxLeft + 'px';

///////// AWAY avatar ///////
var awayAvatarTop = awayBoxHeight * 0.1;
var awayAvatarLeft = awayBoxWidth * 0.05;
awayAvatar.style.top = awayAvatarTop + 'px';
awayAvatar.style.left = awayAvatarLeft + 'px';

var awayAvatarHeight = awayBoxHeight * 0.7;
awayAvatar.style.width = awayAvatarHeight + 'px';
awayAvatar.style.height = awayAvatarHeight + 'px';
if (awayAvatarUrl) {
    awayAvatar.style.background = 'url(\'' + awayAvatarUrl + '\')';
    awayAvatar.style.backgroundSize = 'cover';
}
//username span
var awayUserNameSpan = document.getElementById('awayUserName');
var awayUserNameSpanWidth = 0.6 * awayBoxWidth;
var awayUserNameSpanHeight = 0.1 * awayBoxHeight;
awayUserNameSpan.style.width = awayUserNameSpanWidth + 'px';
awayUserNameSpan.style.height = awayUserNameSpanHeight + 'px';

var awayUserNameSpanTop = awayBoxHeight * 0.25;
var awayUserNameSpanLeft = awayBoxWidth * 0.05 + awayAvatarHeight;
awayUserNameSpan.style.top = awayUserNameSpanTop + 'px';
awayUserNameSpan.style.left = awayUserNameSpanLeft + 'px';

/////////////////// VERSUS SPAN ///////////////////
var versusSpanLeft = 1.15 * selfBoxWidth;
var versusSpanTop = 1.5 * selfAwayBoxTop;

versusSpan.style.left = versusSpanLeft + 'px';
versusSpan.style.top = versusSpanTop + 'px';

var result = JSON.parse(resultString);
var resultArr = result.result.challenger.details.split('|');

/////
var scoreTableTop = selfAwayBoxTop + selfBox.offsetHeight;
var scoreRows = document.getElementById('scoreRows');
resultTable.style.left = selfBox.style.left;
resultTable.style.top = scoreTableTop + 'px';
resultTable.style.width = (baseWidth - (selfBoxLeft * 2)) + 'px';
resultTable.style.height = baseWidth * 0.4 + 'px';

resultArr.forEach(function (res) {
    var data = res.split(',');
    var questionNode = document.createElement('div');
    questionNode.className = questionNode.className + ' score-row';


    var questionTypeNode = document.createElement('div');
    var questionTypeText = document.createTextNode('? Question Type');
    questionTypeNode.className = questionTypeNode.className + ' score-row-title';
    questionTypeNode.appendChild(questionTypeText);
    questionNode.appendChild(questionTypeNode);

    var selfScoreNode = document.createElement('div');
    selfScoreNode.className = selfScoreNode.className + ' score-row-score score-row-seconds';
    var selfTextNode = document.createTextNode('You');
    selfScoreNode.appendChild(selfTextNode);
    questionNode.appendChild(selfScoreNode);

    var awayScoreNode = document.createElement('div');
    awayScoreNode.className = awayScoreNode.className + ' score-row-score score-row-seconds';
    var awayTextNode = document.createTextNode(data[2]);
    awayScoreNode.appendChild(awayTextNode);
    questionNode.appendChild(awayScoreNode);

    scoreRows.appendChild(questionNode)
});

//Hints Used
var hintsUsedBox = document.getElementById('hintsUsedBox');
var hintUsedTop = scoreTableTop + resultTable.offsetHeight;
hintsUsedBox.style.left = selfBox.style.left;
hintsUsedBox.style.top = hintUsedTop + 'px';
hintsUsedBox.style.width = resultTable.style.width;
var awayHintText = document.createTextNode(result.result.challenger.hintsUsed);
awayHintsUsed.appendChild(awayHintText);

//Winning Streak
var winningStreakBox = document.getElementById('winningStreakBox');
var winningStreakTop = hintUsedTop + hintsUsedBox.offsetHeight;
winningStreakBox.style.left = selfBox.style.left;
winningStreakBox.style.top = winningStreakTop + 'px';
winningStreakBox.style.width = resultTable.style.width;
var awayStreakText = document.createTextNode('x' + result.result.challenger.correctStreak);
awayWinningStreak.appendChild(awayStreakText);

//Total Score
var totalScoreBox = document.getElementById('totalScoreBox');
var totalScoreBoxTop = winningStreakTop + winningStreakBox.offsetHeight;
totalScoreBox.style.left = selfBox.style.left;
totalScoreBox.style.top = totalScoreBoxTop + 'px';
totalScoreBox.style.width = resultTable.style.width;
var awayScore = document.createTextNode(result.result.challenger.score);
awayTotalScore.appendChild(awayScore);

//Next Button
var nextButton = document.getElementById('nextButtonContainer');
nextButton.style.top = totalScoreBoxTop + totalScoreBox.offsetHeight + 'px';
