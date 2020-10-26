description 'Install CX Commerce v 2005'
name 'cxcomm'
override_attributes 'cxcomm' => {
	'user' => {
		'user' => 'cxcomm',
		'group' => 'cxcomm'
	},
	'install' => {
		'version' => '2005',
		'download_url' => 'file:///tmp/cx/CXCOM200500P_3-70004955.zip',
		'download_checksum' => '5e03f482b79331b11a99f431b8fb8a6e5166293afc81d5f33615ebed1b0f9103',
		'install_spartacus' => true,
		'install_ip' => false,
		'ip_download_url' => 'file:///tmp/cx/CXCOMINTPK200500P_0-80005540.zip',
		'ip_download_checksum' => '52325439740937080d80133893f19a251c7963f2e3177686587209e5846e419b'
	}
}

run_list 'recipe[cxcomm]'