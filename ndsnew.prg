FUNCTION NEW_ROUND(nNumber, nDecimals)
	RETURN ROUND(nNumber, nDecimals)
	
FUNCTION GET_NDS(nSum, nPcNds, lNdsInc)
    nDiv = IIF(lNdsInc, 100.000000 + nPcNds, 100.000000 )
//	S_ERR({"Делитель". str(nDiv)})
	nRet = nSum * nPcNds / nDiv
	RETURN NEW_ROUND(nRet, 2)
	
FUNCTION GET_SUM(nSum, nSumNds, lNdsInc)
    nRet = IIF(lNdsInc, nSum, nSum + nSumNds)
	RETURN NEW_ROUND(nRet, 2)
	
FUNCTION GET_SUM_WO_NDS(nSum, nSumNds, lNdsInc)
    nRet = IIF(lNdsInc, nSum - nSumNds, nSum)
	RETURN NEW_ROUND(nRet, 2)