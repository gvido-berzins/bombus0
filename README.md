# Bombus piezīmes

```
flutter create bombus
cd bombus
flutter run
```

Mērķis
Ar datorredzi noteikt sugas

Problēmas
- Ļoti daudz sugas

Risinājumi:
- Galvenie mājieni, kas tas varētu būt

Workflow:
1. Redzi bombusu
2. Iefilmē ar lietotni
3. Lietotne pieraksta galvenos lietas
4. Izmantojot datubāzi ar iepriekš aprakstītajām sugām
5. Kad skenēšana ir galā, tad ir nākamā lapa ar tuvākajiem kandidātiem

Ja nevar saprast, tad tiek saglabāts video un bildes ar aprakstu

Sarakstu vai galeriju, kur ir bildes ar visām sugām, kuras mēs varam izfiltrēt
beigās ir daži rezultāti, kuriem ir vairāks bildes ar kurām var salīdzināt.

Galvenās fīčas:
1. Skenēšana (wip 2)
2. Galerija ar filtriem (wip 0)
3. Salīdzināšana (wip 1)
4. Pieraksti ar iefilmēšanu (un pievienot datus) (wip 1)

pieraksti:
- kur tu atradi - var automātiski, bet aprakstu var pievienot
- jebkādas piezīmes - vienkārši bloku ar tekstu - "komentāri"

Datubāze
```
name      string
alias     string
media     list
reference list
features  dict
comments  string
```

data/{suga}/data.json
- saturēs arī bildes


```json
{
	"name": "Bombus Terrestris",
	"references": [
		"https://en.wikipedia.org/wiki/Bombus_terrestris"
	],
	"media": [
		"cloudstorage.link/whatevr.jpg"
	],
	"features": {
		"primary_color": "dzeltens"
	}
}

```




