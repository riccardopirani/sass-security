// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get app_title => 'CyberGuard';

  @override
  String get login => 'Accedi';

  @override
  String get signup => 'Registrati';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get name => 'Nome';

  @override
  String get company_name => 'Nome azienda';

  @override
  String get company_code => 'Codice azienda';

  @override
  String get role => 'Ruolo';

  @override
  String get admin => 'Amministratore';

  @override
  String get employee => 'Dipendente';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get risk_score => 'Punteggio di rischio';

  @override
  String get company_risk_score => 'Punteggio rischio aziendale';

  @override
  String get active_campaigns => 'Campagne phishing attive';

  @override
  String get alerts => 'Avvisi';

  @override
  String get open_alerts => 'Avvisi aperti';

  @override
  String get employees => 'Dipendenti';

  @override
  String get phishing => 'Phishing';

  @override
  String get subscription => 'Abbonamento';

  @override
  String get settings => 'Impostazioni';

  @override
  String get logout => 'Disconnetti';

  @override
  String get save => 'Salva';

  @override
  String get cancel => 'Annulla';

  @override
  String get add_employee => 'Aggiungi dipendente';

  @override
  String get edit_employee => 'Modifica dipendente';

  @override
  String get delete_employee => 'Elimina dipendente';

  @override
  String get no_employees => 'Nessun dipendente';

  @override
  String get loading => 'Caricamento...';

  @override
  String get high => 'Alta';

  @override
  String get medium => 'Media';

  @override
  String get low => 'Bassa';

  @override
  String get severity => 'Gravità';

  @override
  String get send_test => 'Invia test';

  @override
  String get campaign_name => 'Nome campagna';

  @override
  String get campaign_template => 'Template campagna';

  @override
  String get opened => 'Aperto';

  @override
  String get clicked => 'Cliccato';

  @override
  String get sent => 'Inviato';

  @override
  String get pricing => 'Prezzi';

  @override
  String get starter => 'Starter';

  @override
  String get pro => 'Pro';

  @override
  String get business => 'Business';

  @override
  String get per_month => 'mese';

  @override
  String get current_plan => 'Piano attuale';

  @override
  String get upgrade => 'Aggiorna piano';

  @override
  String get manage_subscription => 'Gestisci abbonamento';

  @override
  String get language => 'Lingua';

  @override
  String get choose_language => 'Scegli lingua';

  @override
  String get training_completion => 'Completamento formazione';

  @override
  String get employee_risk_ranking => 'Classifica rischio dipendenti';

  @override
  String get create_account => 'Crea account';

  @override
  String get already_have_account => 'Hai già un account?';

  @override
  String get dont_have_account => 'Non hai un account?';

  @override
  String get sign_in => 'Accedi';

  @override
  String get sign_up_success_check_email =>
      'Account creato. Controlla l\'email per confermare.';

  @override
  String get signup_licensed_seats_label => 'Postazioni licenziate';

  @override
  String get signup_licensed_seats_hint => 'Quanti utenti fatturare (1–50.000)';

  @override
  String get sign_up_opening_checkout =>
      'Account creato. Apertura pagamento sicuro…';

  @override
  String get sign_up_verify_email_then_pay =>
      'Account creato. Conferma l\'email, poi accedi per aprire il checkout e pagare.';

  @override
  String get error_generic => 'Qualcosa è andato storto';

  @override
  String get success => 'Successo';

  @override
  String get empty_alerts => 'Nessun avviso al momento';

  @override
  String get no_campaigns => 'Nessuna campagna phishing';

  @override
  String get refresh => 'Aggiorna';

  @override
  String get plan_starter_desc => 'Protezione essenziale per piccoli team';

  @override
  String get plan_pro_desc => 'Simulazioni avanzate e analisi';

  @override
  String get plan_business_desc => 'Workflow enterprise e supporto prioritario';

  @override
  String get billing => 'Fatturazione';

  @override
  String get status => 'Stato';

  @override
  String get create_campaign => 'Crea campagna';

  @override
  String get send => 'Invia';

  @override
  String get subscription_updated => 'Abbonamento aggiornato';

  @override
  String get mark_read => 'Segna come letto';

  @override
  String get unknown => 'Sconosciuto';

  @override
  String get welcome_back => 'Bentornato';

  @override
  String get security_posture => 'Postura di sicurezza';

  @override
  String get backend_not_configured => 'Backend non configurato';

  @override
  String get setup_instructions =>
      'Imposta SUPABASE_URL e SUPABASE_ANON_KEY tramite --dart-define';

  @override
  String get nav_news => 'News';

  @override
  String get nav_companion => 'Companion';

  @override
  String get nav_security_ops => 'Security Ops';

  @override
  String get subscription_required_title => 'Abbonamento richiesto';

  @override
  String get subscription_required_body =>
      'Il periodo gratuito e terminato oppure non e attivo alcun piano. Completa il pagamento su Stripe per continuare a usare la piattaforma.';

  @override
  String get go_to_plans => 'Vai ai piani';

  @override
  String get exit_app => 'Esci';

  @override
  String get role_security_manager => 'Security Manager';

  @override
  String get role_auditor => 'Auditor';

  @override
  String get open_incidents => 'Incidenti aperti';

  @override
  String get critical_incidents => 'Incidenti critici';

  @override
  String get high_risk_employees_count => 'Dipendenti ad alto rischio';

  @override
  String get metric_benchmark => 'Benchmark';

  @override
  String benchmark_safer_than(int percent) {
    return 'Piu sicuro del $percent% delle aziende';
  }

  @override
  String get security_posture_high_risk => 'Alto rischio';

  @override
  String get security_posture_stable => 'Stabile';

  @override
  String get top_risky_users_week => 'Top 10 utenti a rischio questa settimana';

  @override
  String get no_risky_users_week => 'Nessun utente a rischio questa settimana.';

  @override
  String get monthly_risk_trend => 'Andamento rischio mensile';

  @override
  String get no_trend_data => 'Nessun dato di trend.';

  @override
  String get manager_access_required =>
      'Accesso riservato ad Admin o Security Manager.';

  @override
  String get attack_sim_library => 'Libreria simulazioni attacco';

  @override
  String get custom => 'Personalizzato';

  @override
  String get template_primary => 'Template A (principale)';

  @override
  String get template_ab_test => 'Template B (test A/B)';

  @override
  String get use_ai => 'Usa IA';

  @override
  String get ab_test => 'Test A/B';

  @override
  String get manual_mode => 'Manuale';

  @override
  String get automatic_mode => 'Automatico';

  @override
  String get generate_ai_ab => 'Genera IA A/B';

  @override
  String get ai_templates_generated => 'Template IA generati';

  @override
  String get credential_submitted_short => 'Cred';

  @override
  String get teams_departments_title => 'Team e reparti';

  @override
  String get org_manager_required =>
      'Accesso riservato ad Admin o Security Manager.';

  @override
  String get departments => 'Reparti';

  @override
  String get new_department_name => 'Nome nuovo reparto';

  @override
  String get add_department => 'Aggiungi reparto';

  @override
  String get unnamed => 'Senza nome';

  @override
  String get no_departments => 'Nessun reparto.';

  @override
  String get teams => 'Team';

  @override
  String get department_optional => 'Reparto (opzionale)';

  @override
  String get no_department => 'Nessun reparto';

  @override
  String get new_team_name => 'Nome nuovo team';

  @override
  String get add_team => 'Aggiungi team';

  @override
  String get no_teams => 'Nessun team.';

  @override
  String get security_operations_title => 'Operazioni di sicurezza';

  @override
  String get ops_access_required => 'Accesso riservato a Manager o Auditor.';

  @override
  String get copilot_hint => 'Chiedi: \"Questo evento e pericoloso?\"';

  @override
  String get ask_copilot => 'Chiedi al Copilot';

  @override
  String get refresh_analytics => 'Aggiorna analitiche';

  @override
  String get employee_id => 'ID dipendente';

  @override
  String get suggest_actions => 'Suggerisci azioni';

  @override
  String get execute_actions => 'Esegui azioni';

  @override
  String get sender_email => 'Email mittente';

  @override
  String get subject_field => 'Oggetto';

  @override
  String get body_excerpt => 'Estratto corpo';

  @override
  String get scan_email => 'Analizza email';

  @override
  String get generate_compliance_pdf => 'Genera PDF GDPR/Sicurezza';

  @override
  String get copilot_no_answer => 'Nessuna risposta.';

  @override
  String get no_benchmark_data => 'Nessun dato benchmark.';

  @override
  String get employee_id_required => 'L ID dipendente e obbligatorio';

  @override
  String get email_fields_required =>
      'Mittente, oggetto e corpo sono obbligatori';

  @override
  String get action_applied => 'Azione applicata';

  @override
  String get training_marked_complete => 'Formazione segnata come completata';

  @override
  String get invalid_news_link => 'Link non valido';

  @override
  String get cannot_open_news => 'Impossibile aprire la notizia';

  @override
  String get no_news_for_filter => 'Nessuna news per questo filtro';

  @override
  String get security_news_title => 'Security News';

  @override
  String get security_news_subtitle =>
      'Ultime news gratuite da forum e fonti cyber su virus, hacking e tools.';

  @override
  String get news_topic_all => 'Tutte';

  @override
  String get news_topic_tools => 'Tools';

  @override
  String get news_badge_virus => 'VIRUS';

  @override
  String get news_badge_hacking => 'HACKING';

  @override
  String get news_badge_tools => 'TOOLS';

  @override
  String get read_more => 'Leggi di piu';

  @override
  String get report_incident_title => 'Segnala virus o hacking';

  @override
  String get incident_type => 'Tipo di incidente';

  @override
  String get incident_type_virus => 'Virus';

  @override
  String get incident_type_hacking => 'Hacking';

  @override
  String get severity_critical => 'Critica';

  @override
  String get incident_title => 'Titolo';

  @override
  String get incident_details => 'Dettagli incidente';

  @override
  String get send_alert => 'Invia alert';

  @override
  String get incident_report_sent =>
      'Segnalazione inviata ed email inoltrata all azienda.';

  @override
  String get companion_title => 'Companion sicurezza mobile';

  @override
  String get companion_no_employee => 'Nessun profilo dipendente collegato.';

  @override
  String get companion_user => 'Utente';

  @override
  String get companion_risk_score => 'Punteggio di rischio';

  @override
  String get companion_training => 'Completamento formazione';

  @override
  String get yes => 'Si';

  @override
  String get no => 'No';

  @override
  String get mfa_enabled_label => 'MFA attivo';

  @override
  String get force_mfa_login => 'Forza MFA al prossimo accesso';

  @override
  String get suspicious_activity => 'Attivita sospette';

  @override
  String get no_open_suspicious => 'Nessuna attivita sospetta aperta.';

  @override
  String get approve => 'Approva';

  @override
  String get block => 'Blocca';

  @override
  String get adaptive_learning => 'Micro-formazione adattiva';

  @override
  String get no_training_assignments => 'Nessun incarico di formazione attivo.';

  @override
  String get training_label => 'Formazione';

  @override
  String get assignment_status => 'Stato';

  @override
  String get complete => 'Completa';

  @override
  String get subscription_activation => 'Attivazione abbonamento';

  @override
  String get trial_30_days => 'Gratis 30 giorni';

  @override
  String get stripe_monthly_now => 'Stripe mensile subito';

  @override
  String get trial_then_paywall =>
      'Gratis 30 giorni, poi richiesta abbonamento';

  @override
  String get stripe_pay_immediately => 'Abbonamento mensile con Stripe subito';

  @override
  String get plan_label => 'Piano';

  @override
  String get plan_price_starter => 'Starter - 29 USD/mese';

  @override
  String get plan_price_pro => 'Pro - 79 USD/mese';

  @override
  String get plan_price_business => 'Business - 199 USD/mese';

  @override
  String get password_behavior_risk => 'Rischio comportamento password (0-100)';

  @override
  String get incident_history_risk => 'Rischio storico incidenti (0-100)';

  @override
  String get device_compliance_risk => 'Rischio conformita dispositivo (0-100)';

  @override
  String get behavior_risk => 'Rischio comportamento (0-100)';

  @override
  String get mfa_on => 'ON';

  @override
  String get mfa_off => 'OFF';

  @override
  String get employee_photo => 'Foto profilo';

  @override
  String get change_photo => 'Cambia foto';

  @override
  String get remove_photo => 'Rimuovi foto';

  @override
  String get photo_upload_failed => 'Caricamento foto non riuscito';

  @override
  String get photo_invalid => 'Scegli un immagine valida';

  @override
  String behavior_risk_profile_line(int score, int samples) {
    return 'Profilo rischio comportamentale: $score/100 (campioni: $samples)';
  }

  @override
  String get ai_phishing_engine_title => 'Motore simulazione phishing AI';

  @override
  String get ai_copilot_title => 'Copilot sicurezza AI';

  @override
  String get behavior_benchmark_section =>
      'Analytics comportamento e benchmark';

  @override
  String get auto_remediation_title => 'Auto-remediation';

  @override
  String get email_security_layer_title => 'Livello sicurezza email';

  @override
  String get audit_reports_title => 'Report audit e conformita';

  @override
  String remediation_summary_line(int suggested, int executed, int risk) {
    return 'Suggerite: $suggested | Eseguite: $executed | Rischio: $risk';
  }

  @override
  String email_scan_summary_line(int score, String severity) {
    return 'Punteggio rischio: $score | Gravita: $severity';
  }

  @override
  String report_generated_summary(String file, int chars) {
    return 'Generato: $file | Dimensione PDF: $chars caratteri';
  }

  @override
  String get subscription_plan_flex => 'Prezzo per utente';

  @override
  String get subscription_seats_label => 'Numero utenti (postazioni)';

  @override
  String subscription_pricing_explainer(String base) {
    return 'Il canone mensile usa il risk score aziendale (0–100) e il numero postazioni: base $base + (utenti × 0,22) + (utenti^1,1 × 0,02) + (risk × 0,05).';
  }

  @override
  String subscription_company_risk_value(int score) {
    return 'Risk score aziendale: $score/100';
  }

  @override
  String subscription_estimated_monthly(String amount) {
    return 'Stima: $amount/mese';
  }

  @override
  String get subscription_continue_checkout => 'Vai al pagamento';

  @override
  String get subscription_seats_invalid =>
      'Inserisci un numero valido di utenti (almeno 1).';

  @override
  String get subscription_purchase_history => 'Storico acquisti';

  @override
  String get subscription_no_invoices =>
      'Nessuna fattura. I pagamenti completati compariranno qui.';

  @override
  String get subscription_history_admin_only =>
      'Solo gli admin azienda possono vedere lo storico e annullare l’abbonamento.';

  @override
  String get subscription_invoice_on => 'Data';

  @override
  String get subscription_invoice_ref => 'Fattura';

  @override
  String get subscription_open_invoice => 'Apri';

  @override
  String get subscription_download_pdf => 'PDF';

  @override
  String get subscription_cancel_subscription => 'Annulla abbonamento';

  @override
  String get subscription_cancel_confirm_title => 'Annullare l’abbonamento?';

  @override
  String get subscription_cancel_confirm_body =>
      'L’accesso resta attivo fino alla fine del periodo di fatturazione in corso. Potrai riattivare in qualsiasi momento.';

  @override
  String get subscription_cancel_confirm_action => 'Annulla a fine periodo';

  @override
  String get subscription_cancel_scheduled =>
      'Annullamento programmato alla fine del periodo di fatturazione.';

  @override
  String get subscription_invoice_status_paid => 'Pagata';

  @override
  String get subscription_invoice_status_open => 'Aperta';

  @override
  String get subscription_invoice_status_draft => 'Bozza';

  @override
  String get subscription_invoice_status_void => 'Annullata';

  @override
  String get subscription_invoice_status_uncollectible => 'Insoluta';
}
