//
//  EmailSignUpViewController.swift
//  Gustav
//
//  Created by kaeun on 3/11/26.
//

import UIKit

final class EmailSignUpViewController: UIViewController {

    private let rootView = EmailSignUpView()

    override func loadView() {
        view = rootView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        bindActions()
    }
}

private extension EmailSignUpViewController {
    func setupNavigation() {
        title = ""
        navigationItem.largeTitleDisplayMode = .never
    }

    func bindActions() {
        rootView.formView.signUpButton.addTarget(
            self,
            action: #selector(didTapSignUp),
            for: .touchUpInside
        )

        rootView.formView.policyAgreementView.termsLookButton.addTarget(
            self,
            action: #selector(didTapTermsLook),
            for: .touchUpInside
        )

        rootView.formView.policyAgreementView.privacyLookButton.addTarget(
            self,
            action: #selector(didTapPrivacyLook),
            for: .touchUpInside
        )
    }

    @objc func didTapSignUp() {
        print("Sign Up tapped")
    }

    @objc func didTapTermsLook() {
        print("Terms Look tapped")
    }

    @objc func didTapPrivacyLook() {
        print("Privacy Look tapped")
    }
}
