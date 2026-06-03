import sys, json
from pathlib import Path
from graphify.build import build_from_json
from graphify.cluster import score_all
from graphify.analyze import god_nodes, surprising_connections, suggest_questions
from graphify.report import generate

# Load files
extraction = json.loads(Path('graphify-out/.graphify_extract.json').read_text(encoding='utf-8'))
detection  = json.loads(Path('graphify-out/.graphify_detect.json').read_text(encoding='utf-8'))
analysis   = json.loads(Path('graphify-out/.graphify_analysis.json').read_text(encoding='utf-8'))

G = build_from_json(extraction)
communities = {int(k): v for k, v in analysis['communities'].items()}
cohesion = {int(k): v for k, v in analysis['cohesion'].items()}
tokens = {'input': extraction.get('input_tokens', 0), 'output': extraction.get('output_tokens', 0)}

# Naming dictionary for known namespaces
namespace_mapping = {
    'core_design_system': 'Design System & Theme Tokens',
    'dataconnect_generated': 'Firebase Data Connect Generated SDK',
    'core_theme': 'Application Theme & Color Styling',
    'features_journal_screen': 'Spiritual Journal Feature UI',
    'core_content_provider': 'Spiritual Content Provider & Audio',
    'core_personalized_feed_provider': 'Personalized Spiritual Feed',
    'widgets_animated_effects': 'Ethereal Visual & Particle Effects',
    'features_content_detail_screen': 'Content Detail & Text Viewer',
    'features_book_detail_screen': 'Scripture Book Detail UI',
    'features_category_list_screen': 'Category Selection Screen UI',
    'core_audio_service': 'Background Audio Service',
    'core_audio_provider': 'Audio Playback Manager',
    'core_auth_provider': 'Authentication & User Session Provider',
    'core_cache_service': 'App Caching Service',
    'core_firestore_service': 'Cloud Firestore Database Service',
    'core_journal_provider': 'Journal Entries Provider',
    'core_localization': 'Localization & Language Engine',
    'core_mood_theme_provider': 'Mood-Based Dynamic Themes',
    'core_notification_manager': 'Push Notification Manager',
    'core_rituals_provider': 'Spiritual Rituals Provider',
    'core_sacred_data_repository': 'Sacred Scripture Data Repository',
    'core_spirituality_engine': 'Core Spiritual Recommendation Engine',
    'core_spirituality_provider': 'Spiritual Context Provider',
    'core_stats_provider': 'User Statistics Provider',
    'features_auth_screen': 'User Authentication Screen',
    'features_category_screen': 'Category Details Screen',
    'features_daily_gyaan_screen': 'Daily Wisdom (Gyaan) UI',
    'features_daily_motivation_screen': 'Daily Motivation UI',
    'features_global_player_screen': 'Global Audio Player UI',
    'features_home_screen': 'App Home Dashboard UI',
    'features_naam_jap_screen': 'Naam Jap Chanting Tool',
    'features_onboarding_screen': 'User Onboarding Screen UI',
    'features_profile_screen': 'User Profile Dashboard UI',
    'features_raga_detail_screen': 'Classical Raga Details UI',
    'features_rituals_screen': 'Spiritual Rituals List UI',
    'features_sacred_calendar_screen': 'Sacred Calendar & Festivals UI',
    'features_saint_detail_screen': 'Saint Biography Detail UI',
    'features_search_screen': 'Scripture Search Interface',
    'features_splash_screen': 'Splash Screen & Initializer',
    'services_api_service': 'REST API Service',
    'services_gamification_service': 'Gamification & Achievements Service',
    'services_journal_service': 'Journal Storage Service',
    'services_notification_service': 'Local Notification Service',
    'services_realtime_service': 'Real-time WebSocket Sync Service',
    'services_spiritual_content_service': 'Spiritual Content Retrieval API',
    'services_stats_service': 'User Stats Service',
    'widgets_achievement_dialog': 'Achievement Unlocked Dialog',
    'widgets_ethereal_orb_player': 'Ethereal Orb Audio Visualizer',
    'widgets_mini_player': 'Mini Audio Player Widget',
    'widgets_sacred_card': 'Sacred Content Card Widget',
    'widgets_sacred_morph_widget': 'Sacred Morphing Transition Widget',
    'widgets_xp_progress_bar': 'Experience Points Progress Bar',
    'widgets_xp_toast': 'Experience Points Notification Toast'
}

# Auto-label communities based on member node namespaces
labels = {}
for cid, nodes in communities.items():
    # Count frequency of namespaces in the community
    ns_counts = {}
    for n in nodes:
        # Node name is usually prefix_prefix_name
        # Find namespace prefix
        parts = n.split('_')
        # Skip generic terms
        if len(parts) >= 2:
            ns = parts[0] + '_' + parts[1]
            ns_counts[ns] = ns_counts.get(ns, 0) + 1
            if len(parts) >= 3:
                ns3 = parts[0] + '_' + parts[1] + '_' + parts[2]
                ns_counts[ns3] = ns_counts.get(ns3, 0) + 1.5 # weight longer namespaces higher
    
    # Get highest matching namespace
    best_ns = None
    max_count = 0
    for ns, count in ns_counts.items():
        if count > max_count:
            max_count = count
            best_ns = ns
            
    # Try mapping
    label_name = None
    if best_ns:
        # Check if direct prefix matches
        for known_ns, mapped_name in namespace_mapping.items():
            if best_ns.startswith(known_ns) or known_ns.startswith(best_ns):
                label_name = mapped_name
                break
        
        if not label_name:
            # Fallback to formatting best_ns
            label_name = best_ns.replace('_', ' ').title()
            
    if not label_name and nodes:
        label_name = nodes[0].replace('_', ' ').title()
        
    if not label_name:
        label_name = f'Community {cid}'
        
    labels[cid] = label_name

# Print labels for verification
print("Generated labels:")
for cid in sorted(labels.keys())[:10]:
    print(f"  {cid}: {labels[cid]}")

# Regenerate questions and report
questions = suggest_questions(G, communities, labels)

report = generate(G, communities, cohesion, labels, analysis['gods'], analysis['surprises'], detection, tokens, '.', suggested_questions=questions)
Path('graphify-out/GRAPH_REPORT.md').write_text(report, encoding='utf-8')
Path('graphify-out/.graphify_labels.json').write_text(json.dumps({str(k): v for k, v in labels.items()}, ensure_ascii=False), encoding='utf-8')
print('Report updated with community labels')
