var df = 0;
var zq = 0;
var cw = 0;
var kb = 0;
var sx = 0;

for (var i = 1; i <= rownum; i++) {

	var a = contentPane.getCellValue(0, 2, 2 * i);
	var b = contentPane.getCellValue(0, 0, 2 * i);

	if (a == "" || a == null || a == undefined) {
		kb = kb + 1;
		continue;
	}
	var c = contentPane.getCellValue(0, 3, 1 + (i - 1) * 2);
	var d = a.toString().trim().replace("1", "A").replace("2", "B").replace("3", "C").replace("4", "D");
	switch (c) {
		case 1:
			if (d == b) {
				df = df + 1;
				zq++;
			} else {
				cw++;
			}
			break;
		case 2:
			var e = d.replace(/,/g, "");
			if (e == b) {
				df = df + 2;
				zq++;
			} else {
                cw++;
				var sz = d.split(",");
				for (var j = 0; j < sz.length; j++) {
					if (b.search(sz[j].toString()) >= 0) {
                        df = df + 1;                        
                        sx++;
                        cw--;
						break;
					}
				}				
			}
			break;
		case 3:
			if (d == b) {
				df = df + 1;
				zq++;
			} else {
				cw++;
			}
			break;
	}
}
var row = rownum * 2 + 3;

contentPane.setCellValue(0, 2, row, "最终得分：" + df+"分");
contentPane.setCellValue(0, 2, row+1, "您一共做对了" + zq+"道题,做错了"+cw+"道题,部分正确"+sx+"道题,还有"+kb+"道题未做!");
