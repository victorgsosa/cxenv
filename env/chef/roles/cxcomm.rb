description 'Install CX Commerce v 2005'
name 'cxcomm'
override_attributes 'cxcomm' => {
	'user' => {
		'user' => 'cxcomm',
		'group' => 'cxcomm'
	},
	'install' => {
		'version' => '2005',
		'download_url' => 'file:///tmp/cx/CXCOM200500P_14-70004955.zip',
		'download_checksum' => '2738afa2e40e6a3b2a01c6ba805c3a3938c8bbe13e99a1acb01b5520710fee35',
		'install_spartacus' => true,
		'install_ip' => true,
		'ip_download_url' => 'file:///tmp/cx/CXCOMINTPK200500P_0-80005540.zip',
		'ip_download_checksum' => 'afe8b7be15eb3d96e44f70e802a22aa34e979c78ab09a38121592ef9144ac079'
	}
}

run_list 'recipe[cxcomm]'