<?php
/*
Plugin Name: TBP WAF
Description: Custom plugin for controlling the Web Application Firewall.
Version: 1.1
Author by: Anan P.
*/
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Register the plugin's menu page and settings page 
// Add Settings link to plugin actions
// Add Settings and Deactivate links to plugin actions
function tbp_waf_plugin_actions($actions) {
    $settings_link = '<a href="admin.php?page=tbp-waf-settings">Settings</a>';
    $deactivate_link = '<a href="' . wp_nonce_url(admin_url('plugins.php?action=deactivate&plugin=tbp-waf/tbp-waf.php'), 'deactivate-plugin_tbp-waf/tbp-waf.php') . '">Deactivate</a>';
    
    // Reorder the links
    $actions = array(
        'settings' => $settings_link,
        'deactivate' => $deactivate_link
    );
    
    return $actions;
}
add_filter('plugin_action_links_tbp-waf/tbp-waf.php', 'tbp_waf_plugin_actions');


function tbp_waf_menu_pages() {
    add_menu_page(
        'TBP WAF',
        'TBP WAF',
        'manage_options',
        'tbp-waf',
        'tbp_waf_dashboard_page'
    );

    add_submenu_page(
        'tbp-waf',
        'TBP WAF Settings',
        'Settings',
        'manage_options',
        'tbp-waf-settings',
        'tbp_waf_settings_page'
    );
}
add_action('admin_menu', 'tbp_waf_menu_pages');

// Create the plugin's dashboard page
function tbp_waf_dashboard_page() {
    // Display the dashboard page content
    ?>
    <div class="wrap">
        <h1>TBP WAF (Web Application Firewall)</h1>
        <p>   Welcome to the TBP WAF advance plugin! </p>
        <p> core rules from https://github.com/coreruleset/coreruleset </p>
        <p>
         Advance security developed by   : Anan P.
        </p>
    </div>
    <?php
}

// Create the plugin's settings page
function tbp_waf_settings_page() {
    if (!current_user_can('manage_options')) {
        return;
    }

    // Get saved time values from database
    $saved_hours = get_option('tbp_waf_hours', 1);
    $saved_minutes = get_option('tbp_waf_minutes', 15);

    if (isset($_POST['tbp_waf_action'])) {
        $action = $_POST['tbp_waf_action'];
     
        if ($action === 'on') {
            // Code to execute when turning the WAF on
            $output = "";
            exec('/usr/local/tbp-waf/cmd.sh -a on',$output);
            echo implode("<br>", $output);

        } elseif ($action === 'off') {
            // Get the selected hours and minutes
            $hours = intval($_POST['tbp_waf_hours']);
            $minutes = intval($_POST['tbp_waf_minutes']);
                    
            // Validate and save the time values
            if ($hours >= 0 && $hours < 24 && $minutes >= 0 && $minutes < 60) {
                update_option('tbp_waf_hours', $hours);
                update_option('tbp_waf_minutes', $minutes);
            } else {
                $hours = $saved_hours; // Revert to saved hours value
                $minutes = $saved_minutes; // Revert to saved minutes value
            }
            
            // Code to execute when turning the WAF off
            $output = "";
            exec("/usr/local/tbp-waf/cmd.sh -a off -h $hours -m $minutes", $output);
            
            // Print the output
            echo implode("<br>", $output);
        }
    }elseif (isset($_POST['tbp_waf_status'])) {
        $action = $_POST['tbp_waf_status'];
        $output = shell_exec("/usr/local/tbp-waf/cmd.sh -a check");
        echo "<pre>" . $output . "</pre>";
    }elseif (isset($_POST['tbp_waf_log'])) {
        $output = "";
        $output = shell_exec("/usr/local/tbp-waf/cmd.sh -a log");
        echo "<pre>" . $output . "</pre>";
    }
    // Display the settings page content
    ?>
    <div class="wrap">
        <h1>TBP WAF Settings</h1>
        <form method="post" action="">
            <label>
                <input type="radio" name="tbp_waf_action" value="on">
                Force enable WAF
            </label>
            <br>
            <label>
                <input type="radio" name="tbp_waf_action" value="off">
                
            </label>
            
            <label>
                 Disable and delay turn on enable WAF :
                <input type="number" name="tbp_waf_hours" min="0" max="4" value="<?php echo $saved_hours; ?>"> hours
                <input type="number" name="tbp_waf_minutes" min="0" max="60" value="<?php echo isset($saved_minutes) ? $saved_minutes : 5; ?>">
 minutes
            </label>
             <br>
             <input type="submit" value="submit"> ( WAF engine will affective next 1 minute after submit )
            </form>
            <br>
            <form method="post" action="">
                 <label><input type="hidden" name="tbp_waf_status" value="true" > </label>
                 <input type="submit" value="Check"> last WAF status  
            </form>
            <br>
            <form method="post" action="">
                 <label><input type="hidden" name="tbp_waf_log" value="true" > </label>
                 <input type="submit" value="view log"> get last 10lines  
            </form>
    </div>
    <?php
}
