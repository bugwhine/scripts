BEGIN { part=-1 } 
{
	if ($0 ~ /Device.*Start/) part = 0;
	if (part >= 0) {
		arr[part] = $2;
		part++;
	}
}
END {
	print arr[selected]
}
