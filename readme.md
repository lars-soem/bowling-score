bowling-score
=============

Løsning af [bowling opgaven](https://github.com/skat/bowling-opgave) stillet af SKAT.
Implementeret i [Mojolicious](http://www.mojolicious.org/).

## Algoritmen

Der findes to programmer der benytter samme algoritme, og begge kan afvikles på feks. en Debian maskine.
Eneste afhængighed er pakken `libmojolicious-perl`.

Programmet [bowling-score](bowling-score) er et kommandolinje program. Syntax:
```
bowling-score [info|warn|error]
```
hvor den optionelle parameter bestemmer mængden af output (til stderr).

Programmet [bowling-score-web](bowling-score-web) er en web applikation der feks. kan startes med kommandoen
```
morbo bowling-score-web
```
hvorefter man med en browser kan starte, stoppe og monotorere processen på http://localhost:3000.

## Filer

* [ScoreList.pm](ScoreList.pm): Modul indeholdende bowling score algoritmen.
* [BowlingScore.pm](BowlingScore.pm): Modul indeholdende eventdrevet (non-blocking) algoritme der løbende henter en liste af frames (points)
fra SKAT, returnerer listen af scores og checker response.
* [bowling-score](bowling-score): Simpelt program starter algoritmen i [BowlingScore.pm](BowlingScore.pm).
Programmet fortsætter ind til det stoppes (Ctrl-C) eller en der modtages en HTTP status forskellig fra `200`.
* [bowling-score-web](bowling-score-web): Web applikation der benytter algoritmen i [BowlingScore.pm](BowlingScore.pm).
Applikationen kan startes med kommandoen `morbo bowling-score-web` hvorefter en browser kan starte, stoppe og monotorere processen på
http://localhost:3000.
* [test-algorithm](test-algorithm): Program til manuel test af algoritmen i [ScoreList.pm](ScoreList.pm). Tager en eller flere framelister
fra stdin og skriver resultatet til stdout.
* [test-response](test-response): Program til manuel test af response fra SKAT. Tager som input token og frameliste og
returnerer response.

## Uafsluttede spil

* Data modtaget fra SKAT indeholder nogle gange uafsluttede spil, dvs. spil der ender med spare eller strike
uden de efterfølgende 1 hhv. 2 kast der kræves for at udregne fuld point for den sidste frame.
I disse tilfælde beregner [ScoreList.pm](ScoreList.pm) blot 10 for sidste frame.

## Problemer før 2016-10-17

* Scorelister beregnet fra uafsluttede spil accepteres nogle gange af SKAT, men ikke altid.

* Eksempelvis er scorelisten for 11 strikes `[30,60,...,270,290]`, men dette accepteres ikke af SKAT.
Derimod accepteres `[30,60,...,270,300]` selv om dette kræver 12 strikes.

* Korrekt udregnede scorelister fra **afsluttede** spil afvises nogle af SKAT. Seks eksempler findes i filen [fails.txt](fails.txt).
Verifikation af beregningerne findes i [bowlinggenius-results.pdf](bowlinggenius-results.pdf).

* Filen [fails.txt](fails.txt) indelohder en liste med 6 eksempler hvor SKAT ikke accepterer korrekt data.

* Filen [bowlinggenius-results.pdf](bowlinggenius-results.pdf) indeholder en verifikation af disse 6 eksempler ved
hjælp af http://www.bowlinggenius.com/.
