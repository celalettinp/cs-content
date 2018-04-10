namespace: content.io.cloudslang.cdemo
imports:
  base: io.cloudslang.base
  vm: io.cloudslang.vmware.vcenter.virtual_machines

flow:
    name: deploy_tomcat

    inputs:
      - hostname: "10.0.46.10"
      - username: "Capa1\\1297-capa1user"
      - password: "Automation123"
      - image: "Ubuntu"
      - folder: "Celalettin"

    workflow:
      - uuid_generator:
          do:
            base.utils.uuid_generator: null
          publish:
            - uuid: "${new_uuid}"
          navigate:
            - SUCCESS: trim
      - trim:
          do:
            base.strings.substring:
              - origin_string: '${"celal-"+uuid}'
              - end_index: '14'
          publish:
            - id: '${new_string}'
          navigate:
            - FAILURE: FAILURE
            - SUCCESS: clone_vm
      - clone_vm:
          do:
             vm.clone_virtual_machine:
              - host: '${hostname}'
              - hostname: 'trnesxi3.eswdc.net'
              - username: '${username}'
              - password: '${password}'
              - clone_host: 'trnesxi3.eswdc.net'
              - clone_data_store: 'datastore2'
              - data_center_name: 'CAPA1 Datacenter'
              - is_template: 'false'
              - virtual_machine_name: '${image}'
              - clone_name: '${id}'
              - folder_name: '${folder}'
          navigate:
            - FAILURE: FAILURE
            - SUCCESS: power_on
      - power_on:
          do:
            vm.power_on_virtual_machine:
              - host: '${hostname}'
              - username: '${username}'
              - password: '${password}'
              - virtual_machine_name: '${id}'
          navigate:
            - FAILURE: FAILURE
            - SUCCESS: sleep
      - sleep:
          do:
            base.utils.sleep:
             - seconds: '20'
          navigate:
            - FAILURE: FAILURE
            - SUCCESS: get_details
      - get_details:
          do:
            vm.get_virtual_machine_details:
            - host: '${hostname}'
            - username: '${username}'
            - password: '${password}'
            - hostname: 'trnesxi1.eswdc.net'
            - virtual_machine_name: '${id}'
          publish:
            - details: '${return_result}'
          navigate:
            - FAILURE: FAILURE
            - SUCCESS: SUCCESS
    results:
      - SUCCESS
      - FAILURE