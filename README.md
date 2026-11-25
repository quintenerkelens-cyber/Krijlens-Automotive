# KrijLens Automotive V3 – gedeelde synchronisatie

## Wat is toegevoegd
- Supabase e-mail/wachtwoordaccounts
- Eén gedeelde bedrijfsadministratie voor Quinten en Dylan
- Beide accounts hebben dezelfde lees-/schrijfrechten, inclusief financiën
- Realtime wijzigingsmeldingen; andere telefoon haalt daarna de nieuwste dataset op
- Versiecontrole om overschrijven van gelijktijdige wijzigingen te detecteren
- Lokale cache blijft bestaan als tijdelijke offline kopie

## Gratis starten
Supabase Free biedt op dit moment o.a. 500 MB database, 1 GB opslag en 2 miljoen Realtime-berichten per maand. Free-projecten kunnen na een week inactiviteit worden gepauzeerd en hebben geen automatische databaseback-ups. Controleer de actuele limieten en voorwaarden op https://supabase.com/pricing.

## Installatie
1. Maak een project aan via https://supabase.com/dashboard.
2. Kopieer de Project URL en de publishable key (of legacy anon key) uit Project Settings → API.
3. Open `index.html` en vervang:
   - `PASTE_YOUR_SUPABASE_PROJECT_URL_HERE`
   - `PASTE_YOUR_SUPABASE_PUBLISHABLE_OR_ANON_KEY_HERE`
   met de eigen waarden. Gebruik NOOIT de `service_role` key in de website.
4. Open Supabase → SQL Editor. Plak en run `supabase_setup.sql`.
5. Supabase → Authentication → Providers: laat Email aan. Zet publieke sign-ups uit nadat de twee accounts zijn aangemaakt (of maak accounts via Dashboard).
6. Maak twee accounts aan onder Authentication → Users: Quinten en Dylan. Gebruik unieke sterke wachtwoorden.
7. Kopieer de UUID van beide gebruikers. Pas de laatste INSERT in `supabase_setup.sql` aan met echte UUID's en run die INSERT.
8. Upload alle bestanden uit deze map naar de root van de bestaande GitHub-repository en commit. GitHub Pages publiceert.
9. Open de site op beide iPhones, log in met het eigen account. Maak eerst een JSON-back-up van de lokale V2-data.

## Bestaande lokale gegevens overzetten
Deze V3 cloud begint met een lege bedrijfsdataset. Exporteer eerst een JSON-back-up uit de bestaande V2 app. Importeer die niet blind in twee verschillende apparaten. De veiligste eerste migratie is: op één gekozen apparaat de back-up controleren en vervolgens de dataset eenmalig in de cloud zetten. Dit prototype bevat nog geen automatische migratieknop; laat dit eerst begeleiden voordat je de live administratie overschrijft.

## Belangrijke beperkingen / veiligheid
- De volledige administratie wordt als één JSON-document in Postgres opgeslagen. Dit is praktisch voor een klein team/prototype, maar niet de ideale genormaliseerde eindarchitectuur.
- Foto's en handtekeningen zijn base64 in die JSON. Grote afbeeldingen kunnen de payload en realtime limieten overschrijden; hou foto's beperkt. Realtime stuurt alleen een klein wijzigingssignaal, waarna de volledige dataset wordt opgehaald.
- Optimistic locking voorkomt stil overschrijven bij gelijktijdige wijzigingen, maar bij conflict wordt de nieuwste clouddata geladen en moet de gebruiker de laatste handeling zo nodig opnieuw uitvoeren.
- LocalStorage is niet versleuteld; browsercache en lokale PIN zijn geen beveiligingsmaatregel voor gevoelige administratie.
- De SQL RLS-regels laten alleen expliciet toegevoegde company_members toe. Voeg geen onbekende gebruikers toe. Gebruik geen service_role key in de client.
- Supabase Free heeft geen automatische databaseback-ups en kan pauzeren na inactiviteit. Maak regelmatig JSON-back-ups. Dit is nog geen productie-geaudite systeem.
- PDF-verkoopakte blijft een concept dat juridisch/fiscaal gecontroleerd moet worden.


V4.3: Het door de gebruiker aangeleverde originele KrijLens Automotive-logo is verwerkt in goud. Upload index.html en krijlens-logo-gold.png samen naar de repository-hoofdmap. Laat overige configuratie en Supabase-tabellen ongewijzigd.


## V4.4 – App-icoon bijgewerkt
De iPhone-/PWA-iconen zijn nu opnieuw opgebouwd uit het originele KE-embleem dat de eigenaar heeft aangeleverd, in champagnegoud op donker marineblauw. De bestanden `icon-192.png`, `icon-512.png`, `apple-touch-icon.png` en `favicon-64.png` zijn vervangen. De service-worker-cache is verhoogd naar `krijlens-v44-exact-app-icon`.

Na publiceren op GitHub Pages: verwijder op de iPhone het oude KrijLens-beginschermicoon, open de website opnieuw in Safari en kies Deel > Zet op beginscherm. iOS kan het oude icoon namelijk blijven cachen.


## V4.5 – Handtekeningen
- Verkoper kiezen bij verkoop (Quinten Erkelens of Dylan Krijgsman).
- Handtekeningen naast elkaar in aparte vakken.
- Naam van verkoper en koper duidelijk onder de handtekening.
- PDF-handtekeningen groter en met betere witruimte.
- Service worker cache vernieuwd.
