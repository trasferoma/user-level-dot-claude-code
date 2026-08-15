# Fonti normative per l'italiano nei commenti del codice

Elenco delle fonti a cui attenersi quando una forma linguistica è dubbia, con la gerarchia da
applicare in caso di conflitto. Da consultare solo quando la regola operativa in `SKILL.md` non
copre il caso o quando serve citare la fonte all'utente.

## Indice

1. [Lingua italiana — fonti lessicografiche e grammaticali](#1-lingua-italiana--fonti-lessicografiche-e-grammaticali)
2. [Fonti istituzionali ufficiali per la redazione dei testi](#2-fonti-istituzionali-ufficiali-per-la-redazione-dei-testi)
3. [Norme tecniche internazionali](#3-norme-tecniche-internazionali)
4. [Convenzioni di dominio](#4-convenzioni-di-dominio)
5. [Gerarchia in caso di conflitto](#5-gerarchia-in-caso-di-conflitto)
6. [Riferimenti consultabili](#6-riferimenti-consultabili)

---

## 1. Lingua italiana — fonti lessicografiche e grammaticali

| Ambito | Fonte |
|--------|-------|
| Lessico, ortografia, grafia, plurali, reggenze | **Lo Zingarelli**, Zanichelli (edizione corrente) |
| Riscontro lessicale complementare | **Il Nuovo Devoto-Oli**, Le Monnier; **GRADIT** (De Mauro), UTET |
| Definizioni, terminologia specialistica, neologismi | **Vocabolario Treccani** ed **Enciclopedia Italiana** |
| Riscontro storico e attestazioni | **Grande dizionario della lingua italiana** (Battaglia), UTET |
| Morfologia, sintassi, modi e tempi verbali | **L. Serianni, _Grammatica italiana_**, UTET |
| Sintassi descrittiva, casi complessi | **Renzi–Salvi–Cardinaletti, _Grande grammatica italiana di consultazione_**, il Mulino |
| Accenti, elisione, troncamento, sillabazione | **DOP — Dizionario d'ortografia e di pronunzia** |
| Dubbi d'uso, forestierismi, questioni controverse | **Accademia della Crusca**, servizio di consulenza linguistica |
| Norme redazionali editoriali | **Zanichelli, _Manuale di stile_** |

L'Accademia della Crusca, fondata nel 1583, è la più antica accademia linguistica del mondo ed è
membro della federazione europea delle istituzioni linguistiche nazionali (EFNIL); Zanichelli,
Treccani e UTET sono gli editori lessicografici di riferimento in ambito accademico.

## 2. Fonti istituzionali ufficiali per la redazione dei testi

- **Manuale interistituzionale di convenzioni redazionali**, Ufficio delle pubblicazioni
  dell'Unione europea. Pubblicato per la prima volta nel 1997 e oggi disponibile in tutte le
  24 lingue ufficiali dell'UE, contiene una **Parte quarta dedicata alle convenzioni specifiche
  della lingua italiana**: punteggiatura, maiuscole e minuscole, numeri, abbreviazioni. È la fonte
  ufficiale di riferimento per la resa formale del testo italiano.
- **IATE**, banca dati terminologica ufficiale delle istituzioni dell'Unione europea, per la resa
  italiana dei termini tecnici in contesto normativo.
- **Accademia della Crusca e ITTIG-CNR, _Guida alla redazione degli atti amministrativi. Regole e
  suggerimenti_** (2011), elaborata da un gruppo di linguisti, giuristi e informatici e disponibile
  gratuitamente. Contiene regole operative su ortografia, morfologia, lessico e sintassi dei testi
  tecnico-amministrativi, direttamente riusabili per la documentazione tecnica.
- **Direttiva del Ministro per la funzione pubblica dell'8 maggio 2002** sulla semplificazione del
  linguaggio dei testi amministrativi.
- **_Regole e suggerimenti per la redazione dei testi normativi_** (2007), manuale adottato dalle
  Regioni italiane.

## 3. Norme tecniche internazionali

- **ISO 24495-1:2023 — _Plain language, Part 1: Governing principles and guidelines_.** Primo
  standard internazionale sul linguaggio chiaro, elaborato da esperti di 25 paesi in
  rappresentanza di 19 lingue. Stabilisce quattro principi: il testo deve essere **pertinente,
  reperibile, comprensibile e utilizzabile** dal lettore. Lo standard è esplicitamente applicabile
  alla scrittura tecnica e alla maggior parte delle lingue scritte, quindi anche all'italiano.
- **ISO 704:2022 — _Terminology work: principles and methods_** e **ISO 1087:2019 — _Vocabulary_**,
  per la formazione dei termini e la stesura delle definizioni; **ISO 860** per l'armonizzazione di
  terminologie diverse. Il principio di **biunivocità** (a un concetto un solo termine, a un
  termine un solo concetto) viene da qui.
- **ISO/IEC/IEEE 26514:2022 — _Design and development of information for users_**, che definisce
  requisiti di struttura, contenuto e formato dell'informazione destinata agli utenti del software
  e ne fissa gli attributi di qualità: correttezza, chiarezza, concisione, coerenza,
  comprensibilità.
- **ISO/IEC/IEEE 24765 (SEVOCAB)** come vocabolario di riferimento dell'ingegneria del software.
- **ISO 8601** per date e orari; **Sistema Internazionale (SI)** per le unità di misura.

## 4. Convenzioni di dominio

- **Oracle, _How to Write Doc Comments for the Javadoc Tool_**: struttura del commento di
  documentazione, prima frase di sintesi, forma e ordine dei tag. È il riferimento di fatto per il
  Javadoc e vale per l'impianto formale, non per la lingua.
- Glossari di localizzazione italiana dei principali fornitori software, utilizzabili solo per la
  resa dei termini informatici e solo se coerenti con le fonti della sezione 1.

## 5. Gerarchia in caso di conflitto

| Materia | Fonte che prevale |
|---------|-------------------|
| Ortografia, lessico, morfologia, sintassi | Sezione 1 — Zingarelli e Serianni; Crusca per i casi dubbi |
| Punteggiatura, maiuscole, numeri, abbreviazioni | Sezione 2 — Manuale interistituzionale UE, parte italiana |
| Chiarezza, struttura e leggibilità | Sezione 3 — ISO 24495-1 e ISO/IEC/IEEE 26514 |
| Coerenza terminologica | Sezione 3 — ISO 704, con glossario di progetto e IATE |
| Forma tecnica del commento e dei tag | Sezione 4 — convenzioni Javadoc |

Se una forma non è attestata in almeno una di queste fonti, non si usa. Se il dubbio permane dopo
la verifica, riformula la frase con una costruzione più semplice e sicuramente corretta.

## 6. Riferimenti consultabili

| Fonte | Accesso |
|-------|---------|
| Manuale interistituzionale di convenzioni redazionali (UE) | https://style-guide.europa.eu/it/ — libero |
| Guida alla redazione degli atti amministrativi (Crusca, ITTIG-CNR) | https://www.ittig.cnr.it/Ricerca/Testi/GuidaAttiAmministrativi.pdf — libero |
| Accademia della Crusca, consulenza linguistica | https://accademiadellacrusca.it/ — libero |
| ISO 24495-1:2023, Plain language | https://www.iso.org/standard/78907.html — a pagamento |
| ISO 704:2022, Terminology work | https://www.iso.org/standard/79077.html — a pagamento |
| ISO/IEC/IEEE 26514:2022, Information for users | https://www.iso.org/standard/77451.html — a pagamento |
| Oracle, How to Write Doc Comments for the Javadoc Tool | https://www.oracle.com/technical-resources/articles/java/javadoc-tool.html — libero |
| IATE, terminologia ufficiale UE | banca dati pubblica dell'Unione europea |
| Lo Zingarelli, Vocabolario Treccani, DOP | consultazione online o su licenza |

Le norme ISO sono a pagamento: se non sono disponibili, i principi richiamati in questo documento
sono comunque sufficienti a orientare la redazione dei commenti, e le fonti libere delle sezioni 1
e 2 coprono per intero la parte linguistica.
