/**
 * Creates the "Living with flatmates" questionnaire as a Google Form.
 *
 * How to use (about two minutes):
 * 1. Go to https://script.google.com and click "New project".
 * 2. Delete the sample code, paste this whole file, and click Save.
 * 3. Pick "createQuestionnaire" in the function menu and click Run.
 * 4. Approve the permissions when Google asks (it needs to create a form and a response sheet).
 * 5. Open "Execution log" at the bottom. It shows three links: edit the form, share the form, and see the responses.
 *
 * Every question is a long-answer box with no length limit and nothing is required.
 */

var TITLE = 'Living with flatmates';
var DESCRIPTION = 'A questionnaire about finding, choosing and living with flatmates in Germany. ' +
  'Every question is optional. Skip anything you like, and write as much or as little as you want.';

var SECTIONS = [
  {
    "id": "flat",
    "title": "Your flat",
    "questions": [
      {
        "id": "flat1",
        "text": "Tell us about your flat: who lives there, how long you have lived there, and how you ended up there."
      },
      {
        "id": "flat2",
        "text": "Is it a shared flat with one main tenant, a sublet, or something else? How does that work for you?"
      },
      {
        "id": "flat3",
        "text": "Why did you start looking for a flatmate or a room?"
      },
      {
        "id": "flat4",
        "text": "How do you spend your time at home? For example studying, working from home, going out, early or late hours."
      }
    ]
  },
  {
    "id": "find",
    "title": "Finding people",
    "questions": [
      {
        "id": "find1",
        "text": "Where did you search or post, for example WG-Gesucht, friends or social groups? What worked and what did not?"
      },
      {
        "id": "find2",
        "text": "How many people got in touch, and how did you sort them?"
      },
      {
        "id": "find3",
        "text": "What did you write in your ad or profile, and what did you leave out?"
      },
      {
        "id": "find4",
        "text": "What did you want to know about a person that no ad could tell you?"
      },
      {
        "id": "find5",
        "text": "Did you ever worry about fake profiles or your safety while searching? What happened?"
      },
      {
        "id": "find6",
        "text": "How long did the search take, and how did it feel?"
      }
    ]
  },
  {
    "id": "choose",
    "title": "Choosing one person",
    "questions": [
      {
        "id": "choose1",
        "text": "How did you decide whom to meet? What made you say yes or no to someone?"
      },
      {
        "id": "choose2",
        "text": "What did the first meeting or viewing look like? What did you ask, and what do you wish you had asked?"
      },
      {
        "id": "choose3",
        "text": "Did your other flatmates take part in the decision? How did you agree?"
      },
      {
        "id": "choose4",
        "text": "Would comparing candidates side by side have helped? On which points?"
      },
      {
        "id": "choose5",
        "text": "Did you ever turn someone down, or get turned down? How was it done, and how did it feel?"
      },
      {
        "id": "choose6",
        "text": "Looking back, what did you miss when you made your choice?"
      }
    ]
  },
  {
    "id": "agree",
    "title": "Agreeing the rules",
    "questions": [
      {
        "id": "agree1",
        "text": "Before the new person moved in, what did you agree on? For example rent, deposit, house rules, guests, cleaning, quiet hours."
      },
      {
        "id": "agree2",
        "text": "Was anything written down? Where, and did anyone look at it later?"
      },
      {
        "id": "agree3",
        "text": "Did the landlord or main tenant have to agree to the new flatmate? How did that go?"
      },
      {
        "id": "agree4",
        "text": "What did you assume without saying it out loud, and it later caused trouble?"
      },
      {
        "id": "agree5",
        "text": "Who decided the rules, and did everyone feel heard?"
      },
      {
        "id": "agree6",
        "text": "Which rule would you want in place from day one?"
      }
    ]
  },
  {
    "id": "live",
    "title": "Living together",
    "intro": "Where you can, describe a recent real example.",
    "questions": [
      {
        "id": "live1",
        "topic": "Rent and bills.",
        "text": "How do you split rent and bills? Who chases late payments, and how does that feel?"
      },
      {
        "id": "live2",
        "topic": "Groceries and food.",
        "text": "Do you buy and cook together or separately? Who decides, and what causes friction?"
      },
      {
        "id": "live3",
        "topic": "Cleaning and chores.",
        "text": "Who cleans what? How do you decide turns, and what happens when someone skips?"
      },
      {
        "id": "live4",
        "topic": "Guests and partners.",
        "text": "How do you ask before bringing friends or a partner home? What is too much, and what annoys you?"
      },
      {
        "id": "live5",
        "topic": "Noise and sleep.",
        "text": "When is it quiet? Who works from home, and who sleeps early or late?"
      },
      {
        "id": "live6",
        "topic": "Smoking, drinking and parties.",
        "text": "What are the house habits? Did anyone's habits clash with yours?"
      },
      {
        "id": "live7",
        "topic": "Shared spaces and belongings.",
        "text": "What is shared and what is private? Has anything gone missing or been used without asking?"
      },
      {
        "id": "live8",
        "topic": "Talking about problems.",
        "text": "When something bothers you, how do you raise it: in person, in a chat, or not at all?"
      }
    ]
  },
  {
    "id": "wrong",
    "title": "When it went wrong",
    "intro": "Pick one real situation and tell it step by step. This is the most useful part for us.",
    "questions": [
      {
        "id": "wrong1",
        "text": "Tell us about a moment when things went wrong with a flatmate. What happened first?"
      },
      {
        "id": "wrong2",
        "text": "Who was involved, and what did each person do next?"
      },
      {
        "id": "wrong3",
        "text": "How did you talk about it: in person, in a group chat, or not at all?"
      },
      {
        "id": "wrong4",
        "text": "How long did it take to settle, and did anyone move out?"
      },
      {
        "id": "wrong5",
        "text": "What was the real cause: a habit, money, a missing rule, or a misunderstanding?"
      },
      {
        "id": "wrong6",
        "text": "What could have prevented it, before or after the move-in?"
      },
      {
        "id": "wrong7",
        "text": "What one thing would you have wanted at that moment, such as a rule, a reminder, or a way to say it kindly?"
      }
    ]
  },
  {
    "id": "safety",
    "title": "Safety and comfort",
    "intro": "These topics are personal. Share only what you are comfortable with, and skip anything you like.",
    "questions": [
      {
        "id": "safety1",
        "text": "Did you feel more comfortable living with some kinds of people than others? How did that affect your search?"
      },
      {
        "id": "safety2",
        "text": "Have you ever felt unsafe or uncomfortable in a flat or with a candidate? What would have helped?"
      },
      {
        "id": "safety3",
        "text": "Which details on a profile would you keep private, and which would you share?"
      },
      {
        "id": "safety4",
        "text": "What would make you trust a stranger's profile: an ID check, a photo, a reference, a video call?"
      },
      {
        "id": "safety5",
        "text": "If a match became uncomfortable, what would you want to be able to do: reject, block, leave the chat, report?"
      },
      {
        "id": "safety6",
        "text": "Would you want to choose who can see your profile, for example only women or only certain people? Why?"
      }
    ]
  },
  {
    "id": "idea",
    "title": "An idea",
    "intro": "Imagine an app for flatmates with four steps. Match: it suggests people who fit your habits and preferences, and both sides must say yes. Choose: you shortlist, compare, chat, meet and confirm one person. Agree: you both accept shared house rules, rent and chore arrangements before moving in. Live: it helps with rent and grocery splits, a cleaning rota, and asking before guests come over.",
    "questions": [
      {
        "id": "idea1",
        "text": "What is your first reaction? What do you like, and what do you doubt?"
      },
      {
        "id": "idea2",
        "text": "Which of the four steps would you use first, and which would you skip?"
      },
      {
        "id": "idea3",
        "text": "Which feature would have helped you most? For example preference matching, side-by-side comparison, shared house rules, guest requests, rent and grocery splits, or the chore rota."
      },
      {
        "id": "idea4",
        "text": "What would make you trust the app? What would make you delete it?"
      },
      {
        "id": "idea5",
        "text": "What is missing?"
      },
      {
        "id": "idea6",
        "text": "Would you use it in German, in English, or in both?"
      },
      {
        "id": "idea7",
        "text": "What, if anything, would feel fair to pay for?"
      }
    ]
  },
  {
    "id": "end",
    "title": "Last words",
    "questions": [
      {
        "id": "end1",
        "text": "Is there anything we did not ask that matters?"
      },
      {
        "id": "end2",
        "text": "If you could change one thing about how people find flatmates, what would it be?"
      }
    ]
  }
];

function createQuestionnaire() {
  var form = FormApp.create(TITLE);
  form.setDescription(DESCRIPTION);
  form.setConfirmationMessage('Thank you for sharing your experience.');
  form.setProgressBar(true);
  form.setCollectEmail(false);

  form.addSectionHeaderItem().setTitle('About you (optional)');
  form.addTextItem().setTitle('Name or nickname');
  form.addTextItem().setTitle('City');
  form.addCheckboxItem()
    .setTitle('Which of these have you done?')
    .setChoiceValues([
      'I looked for a room in a shared flat',
      'I chose a new flatmate for a flat I already lived in'
    ]);
  form.addTextItem().setTitle('Email or phone (only if you are happy to be contacted)');
  form.addCheckboxItem()
    .setTitle('Contact permission')
    .setChoiceValues(['You may contact me later to show me a prototype']);

  SECTIONS.forEach(function (s, si) {
    var page = form.addPageBreakItem().setTitle((si + 1) + '. ' + s.title);
    if (s.intro) page.setHelpText(s.intro);
    s.questions.forEach(function (q, qi) {
      var title = (si + 1) + '.' + (qi + 1) + ' ' + (q.topic ? q.topic + ' ' : '') + q.text;
      form.addParagraphTextItem().setTitle(title).setRequired(false);
    });
  });

  var sheet = SpreadsheetApp.create(TITLE + ' (responses)');
  form.setDestination(FormApp.DestinationType.SPREADSHEET, sheet.getId());

  Logger.log('Edit the form: ' + form.getEditUrl());
  Logger.log('Share this link with people: ' + form.getPublishedUrl());
  Logger.log('Responses sheet: ' + sheet.getUrl());
}
