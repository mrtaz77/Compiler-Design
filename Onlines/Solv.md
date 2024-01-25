# Online Solvs
- [A1](#a1)


## A1
Accepted solv during evaluation
```cpp
var_declaration | type_specifier ID LTHIRD RTHIRD ASSIGNOP LCURL argument_list RCURL SEMICOLON
				{
					initRule("var_declaration : type_specifier ID LSQUARE RSQUARE ASSIGNOP LCURL argument_list RCURL SEMICOLON ");
					auto idNode = new PTN(symbolToRule($2),@2.F_L);
					idNode->setArraySize($7->getParameters().size());
					$2->setNode(idNode);
					$2->setType("ARRAY");
					auto lSquareNode = new PTN("LSQUARE : [",@3.F_L);
					auto rSquareNode = new PTN("RSQUARE : ]",@4.F_L);
					auto assignOpNode = new PTN("ASSIGNOP : =",@5.F_L);
					auto lCurlNode = new PTN("LCURL : {",@6.F_L);
					auto rCurlNode = new PTN("RCURL : }",@8.F_L);
					auto semiColonNode = new PTN("SEMICOLON : ;",@9.F_L);
					$$ = (new PTN(current_rule,@$.F_L,@$.L_L))
					->addChildrenToNode(9,$1,idNode,lSquareNode,rSquareNode,assignOpNode,lCurlNode,$7,rCurlNode,semiColonNode);
					ids.clear();
					ids.push_back($2);
					insertVariables($1->getType());
				}
```

Alternative solv supporting array initialization in declaration list :
```cpp
declaration_list : declaration_list COMMA ID LTHIRD RTHIRD ASSIGNOP LCURL argument_list RCURL
				{
					initRule("declaration_list : declaration_list COMMA ID LSQUARE RSQUARE ASSIGNOP LCURL argument_list RCURL ");
					auto idNode = new PTN(symbolToRule($3),@3.F_L);
					idNode->setArraySize($8->getParameters().size());
					$3->setNode(idNode);
					$3->setType("ARRAY");
					auto commaNode = new PTN("COMMA : ,",@2.F_L);
					auto lSquareNode = new PTN("LSQUARE : [",@4.F_L);
					auto rSquareNode = new PTN("RSQUARE : ]",@5.F_L);
					auto assignOpNode = new PTN("ASSIGNOP : =",@6.F_L);
					auto lCurlNode = new PTN("LCURL : {",@7.F_L);
					auto rCurlNode = new PTN("RCURL : }",@9.F_L);
					$$ = (new PTN(current_rule,@$.F_L,@$.L_L))
					->addChildrenToNode(9,$1,commaNode,idNode,lSquareNode,rSquareNode,assignOpNode,lCurlNode,$8,rCurlNode);
					ids.push_back($3);
				}
				| ID LTHIRD RTHIRD ASSIGNOP LCURL argument_list RCURL
				{
					initRule("declaration_list : ID LSQUARE RSQUARE ASSIGNOP LCURL argument_list RCURL ");
					auto idNode = new PTN(symbolToRule($1),@1.F_L);
					idNode->setArraySize($6->getParameters().size());
					$1->setNode(idNode);
					$1->setType("ARRAY");
					auto lSquareNode = new PTN("LSQUARE : [",@2.F_L);
					auto rSquareNode = new PTN("RSQUARE : ]",@3.F_L);
					auto assignOpNode = new PTN("ASSIGNOP : =",@4.F_L);
					auto lCurlNode = new PTN("LCURL : {",@5.F_L);
					auto rCurlNode = new PTN("RCURL : }",@7.F_L);
					$$ = (new PTN(current_rule,@$.F_L,@$.L_L))
					->addChildrenToNode(7,idNode,lSquareNode,rSquareNode,assignOpNode,lCurlNode,$6,rCurlNode);
					ids.clear();
					ids.push_back($1);
				}
				;
```