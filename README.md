# Toki Pona Custom Dictionary

A Flutter application that helps you learn Toki Pona, and comes with a customisable dictionary!

## Core Features
- Base Dictionary of ~120 words
- Upload your own custom definitions!!!
- Dictionary Search 
- View Toki Pona words (sitelen pona) and definitions
- Quiz yourself on sitelen pona, words, and definitions

## Screenshots

### Dictionary
Search for Toki Pona words and view their definitions

<img src="toki_pona_learner/images/dict.png" alt="Dictionary" width="25%">

### View Words
Browse through the Toki Pona (sitelen pona) and their words

<img src="toki_pona_learner/images/view_words.png" alt="View Words" width="25%">

### Practice
Practice Toki Pona through different types of quizzes!
#### Quiz Options
Choose different quiz types to practice Toki Pona!

<img src="toki_pona_learner/images/quiz_options.png" alt="Quiz Options" width="25%">

#### Definition to Symbol
Match definitions to their corresponding symbols

<img src="toki_pona_learner/images/def_to_sym.png" alt="Definition to Symbol" width="25%">

#### Definition to Word
Match definitions to their corresponding words

<img src="toki_pona_learner/images/def_to_word.png" alt="Definition to Word" width="25%">

#### Symbol to Word
Match symbols to their corresponding words

<img src="toki_pona_learner/images/sym_to_word.png" alt="Symbol to Word" width="25%">

#### Word to Symbol
Match words to their corresponding symbols

<img src="toki_pona_learner/images/word_to_sym.png" alt="Word to Symbol" width="25%">

#### Quiz Summary
View your quiz results!

<img src="toki_pona_learner/images/quiz_summary.png" alt="Quiz Summary" width="25%">

### Upload Custom Dictionary
Upload your own custom dictionary CSV file to add new words.

<img src="toki_pona_learner/images/upload_csv.png" alt="Upload Custom Dictionary" width="25%">

## Installation
1. Clone repo: 
```bash
   git clone https://github.com/kyle-t01/toki_pona_learn.git .
   cd toki_pona_learner
```
2. Install Flutter SDK then get Flutter packages
```bash
   flutter pub get
```
3. Running the App on Windows
```bash
   flutter run 
```


## Future
- some more internal testing
- release app on Google Play for Android devices
- make project open source
- update word dataset

## Acknowledgements
Font: sitelenselikiwenasuki.ttf, https://github.com/kreativekorp/sitelen-seli-kiwen (jan Lepeka/Rebecca Bettencourt)
Word Dataset: words adapated from Sonja Lang's "Toki Pona: The Language of Good"

## Dataset
CSV file: 
in the form of: word - partofspeech - definition
https://github.com/kyle-t01/toki_pona_learn/blob/main/toki_pona_learner/assets/original_toki_pona_dict.csv

```csv
"moku","noun","meal"
"moku","noun","food"
"moku","verb","to eat"
"moku","verb","drink"
"moku","verb","consume"
```