import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import 'dart:async';
import "../../views/screens/widgets/word_card.dart";
import "../../views/screens/widgets/compact_word_card.dart";
import "../../views/screens/summary.dart";
import '../../models/word_fact.dart';
import '../../models/word.dart';
import '../../models/practice_type.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({Key? key}) : super(key: key);

  @override
  _PracticeScreenState createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  final DatabaseHelper db = DatabaseHelper();
  int numQuestions = 10;
  int currQIndex = -1;
  int answeredWith = -1;
  List<int> wordIDList = [];
  int correctAnswers = 0;
  Map<WordFact, bool> results = {};
  List<WordFact> currentQuizOptions = [];
  late WordFact currentWordFact;
  bool isLoading = true;
  bool infiniteQuiz = false;
  bool finishedQuiz = false;
  bool isCorrect = false;
  bool justAnswered = false;
  bool alreadyShowingSummary = false;
  QuestionContent questionContent = QuestionContent.definitions;
  AnswerContent answerContent = AnswerContent.words;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPreQuizScreen();
    });
  }

  Future<void> _initialiseQuiz() async {
    await _loadWordIDList();
    await _loadNextQuizWord();
  }

  Future<void> _showPreQuizScreen() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.zero,
          child: AlertDialog(
            title: const Text('Quiz Format'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildQuizOption('Symbol to Words', QuestionContent.symbols,
                    AnswerContent.words),
                _buildQuizOption('Word to Symbols', QuestionContent.words,
                    AnswerContent.symbols),
                _buildQuizOption('Definitions to Words',
                    QuestionContent.definitions, AnswerContent.words),
                _buildQuizOption('Definitions to Symbols',
                    QuestionContent.definitions, AnswerContent.symbols),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuizOption(
      String title, QuestionContent qContent, AnswerContent aContent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 0),
      child: ListTile(
        tileColor: const Color.fromARGB(255, 63, 63, 63).withOpacity(0.1),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () async {
          Navigator.of(context).pop();
          setState(() {
            questionContent = qContent;
            answerContent = aContent;
          });

          await _initialiseQuiz();
        },
      ),
    );
  }

  Future<void> _loadWordIDList() async {
    QuestionFormat questionFormat = QuestionFormat.definitions;

    if (questionContent == QuestionContent.symbols ||
        questionContent == QuestionContent.words) {
      questionFormat = QuestionFormat.symbols;
    } else if (questionContent == QuestionContent.definitions) {
      questionFormat = QuestionFormat.definitions;
    }
    List<int> randomIDList = await db.getRandomWordIDList(questionFormat);
    setState(() {
      wordIDList = randomIDList;
      isLoading = true;
    });
  }

  Future<void> _loadNextQuizWord() async {
    if (currQIndex >= wordIDList.length - 1) {
      setState(() {
        currQIndex = wordIDList.length;
        finishedQuiz = true;
      });

      // check if finished quiz
      if (finishedQuiz == true && alreadyShowingSummary == false) {
        _showSummary();
      }
      return;
    }

    setState(() {
      isLoading = true;
      currQIndex++;
    });

    WordFact nextWordFact = await db.getWordFactByID(wordIDList[currQIndex]);
    List<WordFact> nextOptions = await db.getQuizOptions(nextWordFact);

    setState(() {
      currentWordFact = nextWordFact;
      currentQuizOptions = nextOptions;
      isLoading = false;
    });
  }

  void _showSummary() {
    setState(() {
      alreadyShowingSummary = true;
    });
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SummaryScreen(results: results)),
    );

    return;
  }

  Future<void> _handleOptionTap(int selectedIndex) async {
    bool correct;
    bool answered = true;
    if (selectedIndex == -1) {
      correct = false;
    } else {
      correct = (currentWordFact == currentQuizOptions[selectedIndex]);
    }

    setState(() {
      justAnswered = answered;
      isCorrect = correct;
      answeredWith = selectedIndex;
      results[currentWordFact] = isCorrect;
    });

    if (selectedIndex == -1) {
      _viewWordCard(currentWordFact);
    }

    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      justAnswered = false;
      isCorrect = false;
      answeredWith = -1;
    });

    await _loadNextQuizWord();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _handleExit();
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildQuizContent(),
    );
  }

  void _handleExit() {
    setState(() {
      finishedQuiz = true;
    });
    _showSummary();
  }

  Widget _buildBottomBar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 40.0,
        padding: const EdgeInsets.all(0.0),
        child: ElevatedButton(
          onPressed: () async {
            await _handleOptionTap(-1);
          },
          child: const Text("I don't know"),
        ),
      ),
    );
  }

  Widget _buildQuizContent() {
    return Column(
      children: [
        _buildProgressBar(),
        _buildQuestion(),
        _buildOptionsList(),
        const Spacer(),
        _buildBottomBar(),
      ],
    );
  }

  Widget _buildProgressBar() {
    return SizedBox(
      height: 20,
      child: Center(
        child: Text(
          '${(currQIndex)} / ${wordIDList.length}',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildQuestion() {
    if (questionContent == QuestionContent.symbols) {
      return _questionSymbol();
    } else if (questionContent == QuestionContent.words) {
      return _questionWord();
    } else if (questionContent == QuestionContent.definitions) {
      return _questionDefinitions();
    }
    return const Text("child not implemented!");
  }

  Widget _questionSymbol() {
    return Text(
      currentWordFact.word.word,
      style: const TextStyle(
        fontSize: 80,
        fontFamily: 'sitelenselikiwen',
      ),
    );
  }

  Widget _questionWord() {
    return Text(
      currentWordFact.word.word,
      style: const TextStyle(
        fontSize: 32,
        fontFamily: 'Roboto',
      ),
    );
  }

  Widget _questionDefinitions() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeight = MediaQuery.of(context).size.height;
        final cardHeight = maxHeight * 0.45;
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: cardHeight,
          ),
          child: SingleChildScrollView(
            child: CompactWordCard(
              wordFact: currentWordFact,
              hideHeader: true,
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionsList() {
    List<WordFact> options = _generateOptions();
    return ListView.builder(
      shrinkWrap: true,
      itemCount: options.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
          child: ElevatedButton(
            onPressed: () async {
              await _handleOptionTap(index);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: (index != answeredWith)
                  ? null
                  : (justAnswered && isCorrect ? Colors.green : Colors.red),
            ),
            child: _buildOption(options[index]),
          ),
        );
      },
    );
  }

  Widget _buildOption(WordFact wordFact) {
    if (answerContent == AnswerContent.symbols) {
      return _buildOptionSymbol(wordFact);
    } else if (answerContent == AnswerContent.words) {
      return _buildOptionWord(wordFact);
    } else {
      return const Text("unknown answer");
    }
  }

  Widget _buildOptionSymbol(WordFact wordFact) {
    return Text(
      wordFact.word.word,
      style: const TextStyle(
        fontSize: 32,
        fontFamily: 'sitelenselikiwen',
      ),
    );
  }

  Widget _buildOptionWord(WordFact wordFact) {
    return Text(
      wordFact.word.word,
      style: const TextStyle(
        fontSize: 24,
        fontFamily: 'Roboto',
      ),
    );
  }

  void _viewWordCard(WordFact wordFact) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(0),
          child: Scaffold(
            appBar: AppBar(
              title: Text(wordFact.word.word),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            body: CompactWordCard(
              wordFact: wordFact,
              hideHeader: false,
            ),
          ),
        );
      },
    );
  }

  List<WordFact> _generateOptions() {
    return currentQuizOptions;
  }
}
