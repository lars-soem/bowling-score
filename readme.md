bowling-score
=============

Løsning af [bowling opgaven](https://github.com/skat/bowling-opgave) stillet af SKAT.
Implementeret i [Mojolicious](http://www.mojolicious.org/).

## Programmet

Programmet [bowling-score](bowling-score) kan afvikles på feks. en Debian maskine - eneste afhængighed er pakken `libmojolicious-perl`.

Syntax:
```
bowling-score [debug|info|warn|error]
```
hvor den optionelle parameter bestemmer mængden af output (til stderr).

## Filer

* [ScoreList.pm](ScoreList.pm): Modul indeholdende bowling score algoritmen.
* [bowling-score](bowling-score): Program der henter en liste af frames (points) fra SKAT, returnerer listen af scores
og checker response. Programmet fortsætter ind til det stoppes (Ctrl-C) eller en der
modtages en HTTP status forskellig fra `200`.
* [fails.txt](fails.txt): Liste med 6 eksempler hvor SKAT ikke accepterer korrekt data.
* [bowlinggenius-results.pdf](bowlinggenius-results.pdf): Verifikation af disse 6 eksempler ved hjælp af http://www.bowlinggenius.com/.
* [test-algorithm](test-algorithm): Program til manuel test af algoritmen i [ScoreList.pm](ScoreList.pm). Tager en eller flere framelister
fra stdin og skriver resultatet til stdout.
* [test-response](test-response): Program til manuel test af response fra SKAT. Tager som input token og frameliste og
returnerer response.

## Problemer

* Data modtaget fra SKAT indeholder nogle gange uafsluttede spil, dvs. spil der ender med spare eller strike
uden de efterfølgende 1 hhv. 2 kast der kræves for at udregne fuld point for den sidste frame.
I disse tilfælde beregner [ScoreList.pm](ScoreList.pm) blot 10 for sidste frame.
Denne scoreliste accepteres nogle gange af SKAT, men ikke altid.

* Eksempelvis er scorelisten for 11 strikes `[30,60,...,270,290]`, men dette accepteres ikke af SKAT.
Derimod accepteres `[30,60,...,270,300]` selv om dette kræver 12 strikes.

* Korrekt udregnede scorelister fra **afsluttede** spil afvises nogle af SKAT. Seks eksempler findes i filen [fails.txt](fails.txt).
Verifikation af beregningerne findes i [bowlinggenius-results.pdf](bowlinggenius-results.pdf).
