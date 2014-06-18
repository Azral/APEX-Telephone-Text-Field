    FUNCTION render_masked_field(p_item                IN apex_plugin.t_page_item,
                               p_plugin              IN apex_plugin.t_plugin,
                               p_value               IN VARCHAR2,
                               p_is_readonly         IN BOOLEAN,
                               p_is_printer_friendly IN BOOLEAN)
    RETURN apex_plugin.t_page_item_render_result IS
    -- It's better to have named variables instead of using the generic ones,
    -- makes the code more readable
    l_mask_enable apex_application_page_items.attribute_02%TYPE := p_item.attribute_02;
    l_mask_type   apex_application_page_items.attribute_01%TYPE := p_item.attribute_01;
    l_mask   apex_application_page_items.attribute_03%TYPE := p_item.attribute_03;
    l_showMaskOnHover apex_application_page_items.attribute_04%TYPE := p_item.attribute_04;
    l_autoUnmask apex_application_page_items.attribute_05%TYPE := p_item.attribute_05;
    
  
    l_name          VARCHAR2(30);
    l_plugin_params VARCHAR2(1000);
    l_json_file     VARCHAR2(1000);
    l_result        apex_plugin.t_page_item_render_result;
  BEGIN
  
    IF p_is_readonly OR p_is_printer_friendly THEN
      -- emit hidden field if necessary
      apex_plugin_util.print_hidden_if_readonly(p_item_name           => p_item.name,
                                                p_value               => p_value,
                                                p_is_readonly         => p_is_readonly,
                                                p_is_printer_friendly => p_is_printer_friendly);
      -- emit display span with the value
      apex_plugin_util.print_display_only(p_item_name        => p_item.name,
                                          p_display_value    => p_value,
                                          p_show_line_breaks => FALSE,
                                          p_escape           => TRUE,
                                          p_attributes       => p_item.element_attributes);
    ELSE
      -- Because the page item saves state, we have to call get_input_name_for_page_item
      -- which generates the internal hidden p_arg_names field. It will also return the
      -- HTML field name which we have to use when we render the HTML input field.
      l_name := apex_plugin.get_input_name_for_page_item(FALSE);
      sys.htp.p('<input type="text" name="' || l_name || '" id="' ||
                p_item.name || '" ' || 'value="' ||
                sys.htf.escape_sc(p_value) || '" size="' ||
                p_item.element_width || '" ' || 'maxlength="' ||
                p_item.element_max_length || '" ' ||
                coalesce(p_item.element_attributes,
                         'class="masked_text_field"') || ' />');
    
      -- Register the javascript library the plug-in uses.
      apex_javascript.add_library(p_name      => 'apex.jquery.inputmask-multi',
                                  p_directory => p_plugin.file_prefix,
                                  p_version   => NULL);
      apex_javascript.add_library(p_name      => 'apex.jquery.inputmask',
                                  p_directory => p_plugin.file_prefix,
                                  p_version   => NULL);
      apex_javascript.add_library(p_name      => 'apex.jquery.bind-first-0.1.min',
                                  p_directory => p_plugin.file_prefix,
                                  p_version   => NULL); 
    
      -- Initialize the mask for the page item when the page has been rendered.
      -- apex_javascript.add_value and add_attribute are used to make sure that
      -- the values are properly escaped.
      --IF (l_mask_enable = 'N') THEN
    
      --$('#customer_phone').inputmask("+[####################]", maskOpts.inputmask)
      --                           .attr("placeholder", $('#customer_phone').inputmask("getemptymask"));
      IF (l_mask_enable = 'N') THEN
      
        apex_javascript.add_onload_code(p_code => q'[var maskOpts = {
                                inputmask: {
                                    definitions: {
                                        '#': {
                                            validator: "[0-9]",
                                            cardinality: 1
                                        }
                                    },
                                    //clearIncomplete: true,
                                    showMaskOnHover: ]'||lower(l_showMaskOnHover)||q'[,
                                    autoUnmask: ]'||lower(l_autoUnmask)||q'[
                                },
                                match: /[0-9]/,
                                replace: '#',
                                listKey: "mask"
                            };]' ||
                                                  'apex.jQuery("#' ||
                                                  p_item.name ||
                                                  q'[").inputmask("+]'||l_mask||q'[",maskOpts.inputmask).attr(]' ||
                                                  'apex.jQuery("#' ||
                                                  p_item.name ||
                                                  '").inputmask("getemptymask"));');
      ELSE
        l_json_file := p_plugin.file_prefix || 'phones-' ||
                       lower(l_mask_type) || '.json';
        -- IF (l_mask_type = 'ru') THEN
        apex_javascript.add_onload_code(p_code => q'[
        var listM = $.masksSort($.masksLoad(']' ||
                                                  l_json_file ||
                                                  '''), [''#''], /[0-9]|#/, "mask");' || q'[
        var maskOpts = {
                                inputmask: {
                                    definitions: {
                                        '#': {
                                            validator: "[0-9]",
                                            cardinality: 1
                                        }
                                    },
                                    showMaskOnHover: ]'||lower(l_showMaskOnHover)||q'[,
                                    autoUnmask: ]'||lower(l_autoUnmask)||q'[
                                },
                                list:listM,
                                match: /[0-9]/,
                                replace: '#',
                                listKey: "mask"
                            };]' ||
                                                  ' apex.jQuery("#' ||
                                                  p_item.name ||
                                                  '").inputmasks(maskOpts);');
        -- END IF;
      END IF;
    
      -- Tell APEX that this field is navigable
      l_result.is_navigable := TRUE;
    END IF;
    RETURN l_result;
  END render_masked_field;